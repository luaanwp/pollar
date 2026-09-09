// THESIS: A posição financeira nasce do mesmo livro-caixa que a explica; recusa métricas demonstrativas e gráficos sem histórico.
// OWN-WORLD: Superfícies planas contornadas, teal restrito a ações, valores tabulares exatos e estados semânticos do Pollar.
// STORY: A pessoa distingue dinheiro confirmado do projetado, entende o resultado mensal e encontra os lançamentos que moveram as contas.
// FIRST VIEWPORT: Cabeçalho operacional e resumo assimétrico lideram; posições por conta e movimentos recentes formam a segunda leitura.
// FORM: Extensão “fechamento de caixa imediato”, sem concept seed por herdar uma superfície e um sistema precisamente definidos.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/privacy/privacy_mode_provider.dart';
import '../../../app/theme/pollar_theme.dart';
import '../../../core/money/currency.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_form_controls.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../domain/overview_snapshot.dart';
import 'overview_controller.dart';
import 'widgets/overview_account_positions.dart';
import 'widgets/overview_metrics.dart';
import 'widgets/overview_recent_transactions.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(overviewProvider);
    return overview.when(
      loading: () => const PollarLoadingState(
        message: 'Calculando sua posição financeira…',
      ),
      error: (error, stackTrace) => PollarErrorState(
        title: 'Não foi possível calcular os saldos',
        message: 'Os dados continuam salvos. Tente carregar a visão geral novamente.',
        actionLabel: 'Recalcular saldos',
        onRetry: ref.read(overviewProvider.notifier).retry,
      ),
      data: (snapshot) => _OverviewContent(snapshot: snapshot),
    );
  }
}

class _OverviewContent extends ConsumerStatefulWidget {
  const _OverviewContent({required this.snapshot});

  final OverviewSnapshot snapshot;

  @override
  ConsumerState<_OverviewContent> createState() => _OverviewContentState();
}

class _OverviewContentState extends ConsumerState<_OverviewContent> {
  Currency? _selectedCurrency;

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final compact =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    final privacyHidden = ref.watch(privacyModeProvider);
    final summary =
        (_selectedCurrency == null
            ? null
            : snapshot.summaryFor(_selectedCurrency!)) ??
        snapshot.summaryFor(Currency.brl) ??
        (snapshot.summaries.isEmpty ? null : snapshot.summaries.first);

    if (snapshot.isEmpty || summary == null) {
      return _EmptyOverview(onCreateAccount: () => context.go('/accounts/new'));
    }
    final visibleAccounts = snapshot.accounts
        .where((item) => item.balance.confirmed.currency == summary.currency)
        .toList(growable: false);
    final visibleTransactions = snapshot.recentTransactions
        .where((item) => item.displayAmount.currency == summary.currency)
        .toList(growable: false);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PollarSizes.dashboardMax),
        child: ListView(
          padding: EdgeInsets.all(
            compact ? PollarSpacing.x4 : PollarSpacing.x6,
          ),
          children: [
            _OverviewHeader(
              compact: compact,
              currencies: snapshot.summaries
                  .map((item) => item.currency)
                  .toList(growable: false),
              selectedCurrency: summary.currency,
              onCurrencyChanged: (currency) =>
                  setState(() => _selectedCurrency = currency),
              onNewTransaction: () => context.go('/transactions/new'),
            ),
            const SizedBox(height: PollarSpacing.x5),
            OverviewMetrics(
              summary: summary,
              accountCount: visibleAccounts.length,
              privacyHidden: privacyHidden,
            ),
            const SizedBox(height: PollarSpacing.x4),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 880;
                final accounts = OverviewAccountPositions(
                  accounts: visibleAccounts,
                  privacyHidden: privacyHidden,
                  onOpenAccounts: () => context.go('/accounts'),
                );
                final recent = OverviewRecentTransactions(
                  transactions: visibleTransactions,
                  privacyHidden: privacyHidden,
                  onOpenTransactions: () => context.go('/transactions'),
                );
                if (!wide) {
                  return Column(
                    children: [
                      accounts,
                      const SizedBox(height: PollarSpacing.x4),
                      recent,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: accounts),
                    const SizedBox(width: PollarSpacing.x4),
                    Expanded(flex: 6, child: recent),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({
    required this.compact,
    required this.currencies,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.onNewTransaction,
  });

  final bool compact;
  final List<Currency> currencies;
  final Currency selectedCurrency;
  final ValueChanged<Currency> onCurrencyChanged;
  final VoidCallback onNewTransaction;

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Posição atual',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: PollarSpacing.x1),
        Text(
          'Saldos calculados a partir das suas contas e transações.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: context.pollar.textSecondary),
        ),
      ],
    );
    final action = PollarButton(
      label: 'Nova transação',
      leadingIcon: LucideIcons.plus,
      onPressed: onNewTransaction,
      fullWidth: compact,
    );
    final currencyControl = currencies.length > 1
        ? SizedBox(
            key: ValueKey(selectedCurrency.code),
            width: compact ? double.infinity : 150,
            child: PollarSelect<Currency>(
              label: 'Moeda',
              initialValue: selectedCurrency,
              options: [
                for (final currency in currencies)
                  PollarSelectOption(value: currency, label: currency.code),
              ],
              onChanged: (value) {
                if (value != null) onCurrencyChanged(value);
              },
            ),
          )
        : null;
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          copy,
          if (currencyControl != null) ...[
            const SizedBox(height: PollarSpacing.x4),
            currencyControl,
          ],
          const SizedBox(height: PollarSpacing.x4),
          action,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: copy),
        const SizedBox(width: PollarSpacing.x4),
        if (currencyControl != null) ...[
          currencyControl,
          const SizedBox(width: PollarSpacing.x2),
        ],
        action,
      ],
    );
  }
}

class _EmptyOverview extends StatelessWidget {
  const _EmptyOverview({required this.onCreateAccount});

  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Padding(
        padding: const EdgeInsets.all(PollarSpacing.x6),
        child: PollarCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.walletCards,
                size: 28,
                color: context.pollar.primary,
              ),
              const SizedBox(height: PollarSpacing.x4),
              Text(
                'Cadastre sua primeira conta',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: PollarSpacing.x2),
              Text(
                'O saldo confirmado e o projetado aparecerão aqui depois do saldo inicial.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: context.pollar.textSecondary),
              ),
              const SizedBox(height: PollarSpacing.x4),
              PollarButton(
                label: 'Cadastrar conta',
                leadingIcon: LucideIcons.plus,
                onPressed: onCreateAccount,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

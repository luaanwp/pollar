import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app/theme/pollar_theme.dart';
import 'core/money/currency.dart';
import 'core/money/money.dart';
import 'shared/presentation/money_text.dart';

void main() {
  runApp(const ProviderScope(child: PollarApp()));
}

/// App-wide theme mode. Defaults to the platform setting; the top-bar toggle
/// overrides it. A persisted preference replaces this in the settings feature.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}

class PollarApp extends ConsumerWidget {
  const PollarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Pollar',
      debugShowCheckedModeBanner: false,
      theme: PollarTheme.light(),
      darkTheme: PollarTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const OverviewScreen(),
    );
  }
}

/// A demo transaction row for the theme-verification screen. The real model,
/// backed by Drift, arrives in the transactions slice; this only exercises the
/// visual system with representative data.
class _DemoTransaction {
  const _DemoTransaction({
    required this.title,
    required this.category,
    required this.account,
    required this.amount,
  });

  final String title;
  final String category;
  final String account;
  final Money amount;
}

/// Overview ("Visão geral") — the theme applied to real components: a hero
/// balance metric and a recent-transactions card. Data is seeded in-file until
/// the data layer lands.
class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  static Money _brl(int minorUnits) =>
      Money(minorUnits: minorUnits, currency: Currency.brl);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollar = context.pollar;
    final text = Theme.of(context).textTheme;
    final mode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final transactions = <_DemoTransaction>[
      _DemoTransaction(
        title: 'Salário',
        category: 'Renda',
        account: 'Conta corrente',
        amount: _brl(875000),
      ),
      _DemoTransaction(
        title: 'Mercado',
        category: 'Alimentação',
        account: 'Cartão Ouro',
        amount: _brl(-23415),
      ),
      _DemoTransaction(
        title: 'Assinatura de streaming',
        category: 'Serviços',
        account: 'Cartão Ouro',
        amount: _brl(-3990),
      ),
      _DemoTransaction(
        title: 'Reembolso',
        category: 'Trabalho',
        account: 'Conta corrente',
        amount: _brl(12000),
      ),
    ];

    final total = transactions
        .map((t) => t.amount)
        .fold(Money.zero(Currency.brl), (acc, m) => acc + m);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: pollar.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: pollar.border)),
        titleSpacing: PollarSpacing.x6,
        title: Text('Visão geral', style: text.headlineMedium),
        actions: [
          IconButton(
            tooltip: isDark ? 'Tema claro' : 'Tema escuro',
            icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon, size: 20),
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .set(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
          const SizedBox(width: PollarSpacing.x2),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: PollarSizes.dashboardMax),
          child: ListView(
            padding: const EdgeInsets.all(PollarSpacing.x6),
            children: [
              _BalanceCard(total: total),
              const SizedBox(height: PollarSpacing.x6),
              _TransactionsCard(transactions: transactions),
              const SizedBox(height: PollarSpacing.x4),
              _OfflineNote(active: mode != ThemeMode.system),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.total});

  final Money total;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PollarSpacing.x5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SALDO TOTAL',
              style: PollarTypography.eyebrow.copyWith(color: pollar.textMuted),
            ),
            const SizedBox(height: PollarSpacing.x3),
            MoneyText(total, style: PollarTypography.amountHero),
            const SizedBox(height: PollarSpacing.x2),
            Text(
              'Saldo confirmado · atualizado agora',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: pollar.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsCard extends StatelessWidget {
  const _TransactionsCard({required this.transactions});

  final List<_DemoTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PollarSpacing.x2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PollarSpacing.x5,
                PollarSpacing.x3,
                PollarSpacing.x5,
                PollarSpacing.x2,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'TRANSAÇÕES RECENTES',
                  style: PollarTypography.eyebrow.copyWith(
                    color: pollar.textMuted,
                  ),
                ),
              ),
            ),
            for (final (i, t) in transactions.indexed) ...[
              if (i > 0) Divider(height: 1, color: pollar.border),
              _TransactionTile(transaction: t),
            ],
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final _DemoTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    final text = Theme.of(context).textTheme;
    final isIncome = transaction.amount.isPositive;
    final tint = isIncome ? pollar.success : pollar.danger;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PollarSpacing.x5,
        vertical: PollarSpacing.x3,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: pollar.surfaceAlt,
              borderRadius: BorderRadius.circular(PollarRadii.medium),
            ),
            child: Icon(
              isIncome ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
              size: 20,
              color: tint,
            ),
          ),
          const SizedBox(width: PollarSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: text.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  '${transaction.category} · ${transaction.account}',
                  style: text.bodySmall?.copyWith(color: pollar.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: PollarSpacing.x3),
          MoneyText(transaction.amount, showSign: true, colorBySign: true),
        ],
      ),
    );
  }
}

class _OfflineNote extends StatelessWidget {
  const _OfflineNote({required this.active});

  /// Whether the theme has been manually overridden (used only to vary the demo
  /// copy); real offline state comes from the sync feature.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(LucideIcons.wifiOff, size: 16, color: pollar.textMuted),
        const SizedBox(width: PollarSpacing.x2),
        Expanded(
          child: Text(
            'As alterações ficam salvas neste dispositivo e serão '
            'sincronizadas quando a conexão voltar.',
            style: text.bodySmall?.copyWith(color: pollar.textMuted),
          ),
        ),
      ],
    );
  }
}

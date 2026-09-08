import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/privacy/privacy_mode_provider.dart';
import '../../../app/theme/pollar_theme.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/pollar_banner.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/privacy_amount.dart';
import '../../../shared/presentation/status_badge.dart';
import '../../../shared/presentation/transaction_tile.dart';

/// Overview ("Visão geral") — the theme applied to real components: a hero
/// balance metric and a recent-transactions card. Data is seeded in-file until
/// the data layer lands; this screen renders only its scrollable content, the
/// app shell supplies the navigation chrome.
class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  static Money _brl(int minorUnits) =>
      Money(minorUnits: minorUnits, currency: Currency.brl);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyHidden = ref.watch(privacyModeProvider);
    final transactions = <_DemoTransaction>[
      _DemoTransaction(
        title: 'Salário',
        category: 'Renda',
        account: 'Conta corrente',
        amount: _brl(875000),
        kind: TransactionKind.income,
      ),
      _DemoTransaction(
        title: 'Mercado',
        category: 'Alimentação',
        account: 'Cartão Ouro',
        amount: _brl(-23415),
        kind: TransactionKind.expense,
      ),
      _DemoTransaction(
        title: 'Assinatura de streaming',
        category: 'Serviços',
        account: 'Cartão Ouro',
        amount: _brl(-3990),
        kind: TransactionKind.expense,
      ),
      _DemoTransaction(
        title: 'Reembolso',
        category: 'Trabalho',
        account: 'Conta corrente',
        amount: _brl(12000),
        kind: TransactionKind.income,
      ),
    ];

    final total = transactions
        .map((t) => t.amount)
        .fold(Money.zero(Currency.brl), (acc, m) => acc + m);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PollarSizes.dashboardMax),
        child: ListView(
          padding: const EdgeInsets.all(PollarSpacing.x6),
          children: [
            _BalanceCard(total: total, privacyHidden: privacyHidden),
            const SizedBox(height: PollarSpacing.x6),
            _TransactionsCard(
              transactions: transactions,
              privacyHidden: privacyHidden,
            ),
            const SizedBox(height: PollarSpacing.x4),
            const PollarBanner(
              tone: PollarStatusTone.warning,
              icon: LucideIcons.wifiOff,
              title: 'Você está offline',
              message:
                  'As alterações ficam salvas neste dispositivo e serão '
                  'sincronizadas quando a conexão voltar.',
            ),
          ],
        ),
      ),
    );
  }
}

/// A demo transaction row for the overview. The real model, backed by Drift,
/// arrives in the transactions slice; this only exercises the visual system.
class _DemoTransaction {
  const _DemoTransaction({
    required this.title,
    required this.category,
    required this.account,
    required this.amount,
    required this.kind,
  });

  final String title;
  final String category;
  final String account;
  final Money amount;
  final TransactionKind kind;
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.total, required this.privacyHidden});

  final Money total;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    return PollarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SALDO TOTAL',
            style: PollarTypography.eyebrow.copyWith(color: pollar.textMuted),
          ),
          const SizedBox(height: PollarSpacing.x3),
          PrivacyAmount(
            total,
            hidden: privacyHidden,
            style: PollarTypography.amountHero,
          ),
          const SizedBox(height: PollarSpacing.x2),
          Text(
            'Saldo confirmado · atualizado agora',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: pollar.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TransactionsCard extends StatelessWidget {
  const _TransactionsCard({
    required this.transactions,
    required this.privacyHidden,
  });

  final List<_DemoTransaction> transactions;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    return PollarCard(
      padding: PollarCardPadding.none,
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
              TransactionTile(
                title: t.title,
                category: t.category,
                account: t.account,
                amount: t.amount,
                kind: t.kind,
                privacyHidden: privacyHidden,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

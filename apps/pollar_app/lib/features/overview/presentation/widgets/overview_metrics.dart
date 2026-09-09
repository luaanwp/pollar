import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/pollar_theme.dart';
import '../../../../core/money/money.dart';
import '../../../../shared/presentation/pollar_card.dart';
import '../../../../shared/presentation/money_text.dart';
import '../../../../shared/presentation/privacy_amount.dart';
import '../../domain/overview_snapshot.dart';

class OverviewMetrics extends StatelessWidget {
  const OverviewMetrics({
    super.key,
    required this.summary,
    required this.accountCount,
    required this.privacyHidden,
  });

  final OverviewCurrencySummary summary;
  final int accountCount;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final accessible = MediaQuery.textScalerOf(context).scale(1) > 1.3;
      final wide = constraints.maxWidth >= 760 && !accessible;
      final balance = _BalancePositionCard(
        summary: summary,
        accountCount: accountCount,
        privacyHidden: privacyHidden,
      );
      final result = _MonthlyResultCard(
        summary: summary,
        privacyHidden: privacyHidden,
      );
      if (!wide) {
        return Column(
          children: [
            balance,
            const SizedBox(height: PollarSpacing.x4),
            result,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: balance),
          const SizedBox(width: PollarSpacing.x4),
          Expanded(flex: 3, child: result),
        ],
      );
    },
  );
}

class _BalancePositionCard extends StatelessWidget {
  const _BalancePositionCard({
    required this.summary,
    required this.accountCount,
    required this.privacyHidden,
  });

  final OverviewCurrencySummary summary;
  final int accountCount;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    final accessible = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return PollarCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final split = constraints.maxWidth >= 500 && !accessible;
          final confirmed = _MetricBlock(
            title: 'Saldo confirmado',
            amount: summary.confirmed,
            hidden: privacyHidden,
            hero: true,
            helper:
                '$accountCount ${accountCount == 1 ? 'posição ativa' : 'posições ativas'} · ${summary.currency.code}',
          );
          final projected = _MetricBlock(
            title: 'Saldo projetado',
            amount: summary.projected,
            hidden: privacyHidden,
            helper: 'Inclui lançamentos previstos e pendentes',
          );
          final content = split
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: confirmed),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PollarSpacing.x5,
                      ),
                      child: SizedBox(
                        height: 86,
                        child: VerticalDivider(width: 1, color: pollar.border),
                      ),
                    ),
                    Expanded(flex: 5, child: projected),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    confirmed,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: PollarSpacing.x4,
                      ),
                      child: Divider(height: 1, color: pollar.border),
                    ),
                    projected,
                  ],
                );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              content,
              if (!summary.projectedCardDebt.isZero) ...[
                const SizedBox(height: PollarSpacing.x4),
                Container(
                  padding: const EdgeInsets.all(PollarSpacing.x3),
                  decoration: BoxDecoration(
                    color: pollar.surfaceAlt,
                    borderRadius: BorderRadius.circular(PollarRadii.medium),
                  ),
                  child: accessible
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.creditCard,
                                  size: 18,
                                  color: pollar.info,
                                ),
                                const SizedBox(width: PollarSpacing.x2),
                                Expanded(
                                  child: Text(
                                    'Dívida projetada nos cartões',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: pollar.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: PollarSpacing.x2),
                            Align(
                              alignment: Alignment.centerRight,
                              child: PrivacyAmount(
                                summary.projectedCardDebt,
                                hidden: privacyHidden,
                                maskDigits: 5,
                                semantic: MoneySemantic.debt,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(
                              LucideIcons.creditCard,
                              size: 18,
                              color: pollar.info,
                            ),
                            const SizedBox(width: PollarSpacing.x2),
                            Expanded(
                              child: Text(
                                'Dívida projetada nos cartões',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: pollar.textSecondary),
                              ),
                            ),
                            const SizedBox(width: PollarSpacing.x3),
                            PrivacyAmount(
                              summary.projectedCardDebt,
                              hidden: privacyHidden,
                              maskDigits: 5,
                              semantic: MoneySemantic.debt,
                            ),
                          ],
                        ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MonthlyResultCard extends StatelessWidget {
  const _MonthlyResultCard({
    required this.summary,
    required this.privacyHidden,
  });

  final OverviewCurrencySummary summary;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) => PollarCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MetricBlock(
          title: 'Resultado projetado do mês',
          amount: summary.projectedMonthlyResult,
          hidden: privacyHidden,
          hero: true,
          colorBySign: true,
          helper: 'Receitas menos despesas',
        ),
        const SizedBox(height: PollarSpacing.x4),
        _FlowLine(
          label: 'Entradas',
          amount: summary.projectedMonthlyIncome,
          hidden: privacyHidden,
          positive: true,
        ),
        const SizedBox(height: PollarSpacing.x2),
        _FlowLine(
          label: 'Saídas',
          amount: summary.projectedMonthlyExpenses,
          hidden: privacyHidden,
        ),
      ],
    ),
  );
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.title,
    required this.amount,
    required this.hidden,
    required this.helper,
    this.hero = false,
    this.colorBySign = false,
  });

  final String title;
  final Money amount;
  final bool hidden;
  final String helper;
  final bool hero;
  final bool colorBySign;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: PollarSpacing.x2),
      PrivacyAmount(
        amount,
        hidden: hidden,
        maskDigits: hero ? 6 : 5,
        colorBySign: colorBySign,
        showSign: colorBySign && amount.isPositive,
        style: hero
            ? PollarTypography.amountHero
            : PollarTypography.amountStandard,
        semantic: colorBySign ? MoneySemantic.neutral : MoneySemantic.balance,
      ),
      const SizedBox(height: PollarSpacing.x1),
      Text(
        helper,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: context.pollar.textSecondary),
      ),
    ],
  );
}

class _FlowLine extends StatelessWidget {
  const _FlowLine({
    required this.label,
    required this.amount,
    required this.hidden,
    this.positive = false,
  });

  final String label;
  final Money amount;
  final bool hidden;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: context.pollar.textSecondary),
    );
    final amountWidget = PrivacyAmount(
      amount,
      hidden: hidden,
      maskDigits: 5,
      showSign: positive,
      colorBySign: positive,
      semantic: positive ? MoneySemantic.income : MoneySemantic.expense,
    );
    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          labelWidget,
          const SizedBox(height: PollarSpacing.x1),
          Align(alignment: Alignment.centerRight, child: amountWidget),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: labelWidget),
        amountWidget,
      ],
    );
  }
}

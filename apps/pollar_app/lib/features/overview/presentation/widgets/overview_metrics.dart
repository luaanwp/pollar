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
      final wide =
          constraints.maxWidth >= 960 &&
          MediaQuery.textScalerOf(context).scale(1) <= 1.3;
      final balance = _BalancePosition(
        summary: summary,
        accountCount: accountCount,
        hidden: privacyHidden,
      );
      final result = _MonthlyResult(summary: summary, hidden: privacyHidden);
      if (!wide) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            balance,
            const SizedBox(height: PollarSpacing.x6),
            result,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: balance),
          const SizedBox(width: PollarSpacing.x8),
          Expanded(flex: 4, child: result),
        ],
      );
    },
  );
}

class _BalancePosition extends StatelessWidget {
  const _BalancePosition({
    required this.summary,
    required this.accountCount,
    required this.hidden,
  });

  final OverviewCurrencySummary summary;
  final int accountCount;
  final bool hidden;

  @override
  Widget build(BuildContext context) => PollarCard(
    variant: PollarCardVariant.financial,
    child: LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Saldo confirmado',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: PollarSpacing.x2),
          PrivacyAmount(
            summary.confirmed,
            key: const Key('overview-confirmed'),
            animateChanges: true,
            hidden: hidden,
            style: PollarTypography.balanceHeroForWidth(constraints.maxWidth),
            semantic: MoneySemantic.balance,
            allowWrap: true,
            reserveLayout: true,
          ),
          const SizedBox(height: PollarSpacing.x1),
          Text(
            '$accountCount ${accountCount == 1 ? 'posição ativa' : 'posições ativas'} · ${summary.currency.code}',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.pollar.textSecondary),
          ),
          const SizedBox(height: PollarSpacing.x5),
          _AmountLine(
            label: 'Saldo projetado',
            amount: summary.projected,
            hidden: hidden,
            style: PollarTypography.tabular(
              Theme.of(context).textTheme.headlineSmall!,
            ),
          ),
          const SizedBox(height: PollarSpacing.x1),
          Text(
            'Inclui lançamentos previstos e pendentes',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.pollar.textSecondary),
          ),
          if (!summary.projectedCardDebt.isZero) ...[
            const SizedBox(height: PollarSpacing.x4),
            Divider(height: 1, color: context.pollar.borderStrong),
            const SizedBox(height: PollarSpacing.x3),
            _AmountLine(
              label: 'Dívida projetada nos cartões',
              amount: summary.projectedCardDebt,
              hidden: hidden,
              semantic: MoneySemantic.debt,
              icon: LucideIcons.creditCard,
            ),
          ],
        ],
      ),
    ),
  );
}

class _MonthlyResult extends StatelessWidget {
  const _MonthlyResult({required this.summary, required this.hidden});
  final OverviewCurrencySummary summary;
  final bool hidden;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        child: Text(
          'Resultado projetado do mês',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      const SizedBox(height: PollarSpacing.x2),
      PrivacyAmount(
        summary.projectedMonthlyResult,
        hidden: hidden,
        style: PollarTypography.tabular(
          Theme.of(context).textTheme.headlineMedium!,
        ),
        colorBySign: true,
        showSign: summary.projectedMonthlyResult.isPositive,
        semantic: MoneySemantic.neutral,
        allowWrap: true,
        reserveLayout: true,
      ),
      const SizedBox(height: PollarSpacing.x1),
      Text(
        'Receitas menos despesas',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: context.pollar.textSecondary),
      ),
      const SizedBox(height: PollarSpacing.x4),
      _AmountLine(
        label: 'Entradas',
        amount: summary.projectedMonthlyIncome,
        hidden: hidden,
        semantic: MoneySemantic.income,
        positive: true,
      ),
      const SizedBox(height: PollarSpacing.x2),
      _AmountLine(
        label: 'Saídas',
        amount: summary.projectedMonthlyExpenses,
        hidden: hidden,
        semantic: MoneySemantic.expense,
      ),
    ],
  );
}

/// Values always have bounded width, including when large text stacks the pair.
class _AmountLine extends StatelessWidget {
  const _AmountLine({
    required this.label,
    required this.amount,
    required this.hidden,
    this.style,
    this.semantic = MoneySemantic.balance,
    this.positive = false,
    this.icon,
  });

  final String label;
  final Money amount;
  final bool hidden;
  final TextStyle? style;
  final MoneySemantic semantic;
  final bool positive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: context.pollar.textSecondary),
          const SizedBox(width: PollarSpacing.x2),
        ],
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: context.pollar.textSecondary),
          ),
        ),
      ],
    );
    final amountWidget = PrivacyAmount(
      amount,
      hidden: hidden,
      style: style,
      maskDigits: 5,
      semantic: semantic,
      showSign: positive,
      colorBySign: positive,
      allowWrap: true,
      reserveLayout: true,
      alignment: AlignmentDirectional.topEnd,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 280 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              labelWidget,
              const SizedBox(height: PollarSpacing.x1),
              amountWidget,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: labelWidget),
            const SizedBox(width: PollarSpacing.x3),
            Expanded(flex: 5, child: amountWidget),
          ],
        );
      },
    );
  }
}

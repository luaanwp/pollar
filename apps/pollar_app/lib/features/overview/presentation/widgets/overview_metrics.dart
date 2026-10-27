import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/pollar_theme.dart';
import '../../../../core/money/money.dart';
import '../../../../shared/presentation/money_text.dart';
import '../../../../shared/presentation/privacy_amount.dart';
import '../../domain/overview_snapshot.dart';
import 'overview_monthly_flow.dart';

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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _BalancePosition(
        summary: summary,
        accountCount: accountCount,
        hidden: privacyHidden,
      ),
      const SizedBox(height: PollarSpacing.x6),
      _MonthlyResult(summary: summary, hidden: privacyHidden),
    ],
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
  Widget build(BuildContext context) {
    final palette = context.pollar;
    final theme = Theme.of(context);
    final foreground = palette.financialHeroForeground;
    final secondary = palette.financialHeroSecondary;
    return DecoratedBox(
      key: const Key('overview-position-field'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PollarRadii.large),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.financialHeroStart, palette.financialHeroEnd],
        ),
      ),
      // MoneyText and PrivacyAmount share the audited foreground inside this
      // field. No global amount colors or privacy behavior are changed.
      child: Theme(
        data: theme.copyWith(
          textTheme: theme.textTheme.apply(
            bodyColor: foreground,
            displayColor: foreground,
          ),
          extensions: [
            ...theme.extensions.values.where((item) => item is! PollarColors),
            palette.copyWith(textPrimary: foreground, textSecondary: secondary),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= 880 &&
                MediaQuery.textScalerOf(context).scale(1) <= 1.3;
            final inset = wide ? PollarSpacing.x8 : PollarSpacing.x5;
            final balance = LayoutBuilder(
              builder: (context, balanceConstraints) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Saldo confirmado',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: PollarSpacing.x3),
                  PrivacyAmount(
                    summary.confirmed,
                    key: const Key('overview-confirmed'),
                    animateChanges: true,
                    hidden: hidden,
                    style: PollarTypography.positionDisplayForWidth(
                      balanceConstraints.maxWidth,
                    ),
                    semantic: MoneySemantic.balance,
                    allowWrap: true,
                    reserveLayout: true,
                  ),
                  const SizedBox(height: PollarSpacing.x2),
                  Text(
                    '$accountCount ${accountCount == 1 ? 'posição ativa' : 'posições ativas'} · ${summary.currency.code}',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: secondary),
                  ),
                ],
              ),
            );
            final projection = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AmountLine(
                  label: 'Saldo projetado',
                  amount: summary.projected,
                  hidden: hidden,
                  style: PollarTypography.tabular(
                    Theme.of(context).textTheme.headlineMedium!,
                  ),
                ),
                const SizedBox(height: PollarSpacing.x1),
                Text(
                  'Inclui lançamentos previstos e pendentes',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: secondary),
                ),
                if (!summary.projectedCardDebt.isZero) ...[
                  const SizedBox(height: PollarSpacing.x5),
                  _AmountLine(
                    label: 'Dívida projetada nos cartões',
                    amount: summary.projectedCardDebt,
                    hidden: hidden,
                    semantic: MoneySemantic.debt,
                    icon: LucideIcons.creditCard,
                  ),
                ],
              ],
            );
            return Padding(
              padding: EdgeInsets.all(inset),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 6, child: balance),
                        const SizedBox(width: PollarSpacing.x8),
                        Expanded(flex: 4, child: projection),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        balance,
                        const SizedBox(height: PollarSpacing.x5),
                        Divider(
                          height: 1,
                          color: secondary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: PollarSpacing.x4),
                        projection,
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _MonthlyResult extends StatelessWidget {
  const _MonthlyResult({required this.summary, required this.hidden});
  final OverviewCurrencySummary summary;
  final bool hidden;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide =
          constraints.maxWidth >= 880 &&
          MediaQuery.textScalerOf(context).scale(1) <= 1.3;
      final result = Column(
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
        ],
      );
      final flow = OverviewMonthlyFlow(summary: summary, hidden: hidden);
      if (!wide) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            result,
            const SizedBox(height: PollarSpacing.x4),
            flow,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: result),
          const SizedBox(width: PollarSpacing.x8),
          Expanded(flex: 6, child: flow),
        ],
      );
    },
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
    this.icon,
  });

  final String label;
  final Money amount;
  final bool hidden;
  final TextStyle? style;
  final MoneySemantic semantic;
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

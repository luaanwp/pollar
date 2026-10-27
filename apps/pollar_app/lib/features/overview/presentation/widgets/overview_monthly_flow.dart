import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/pollar_theme.dart';
import '../../../../core/money/money.dart';
import '../../../../shared/presentation/money_text.dart';
import '../../../../shared/presentation/pollar_motion.dart';
import '../../../../shared/presentation/privacy_amount.dart';
import '../../domain/overview_snapshot.dart';

/// A comparison of the two existing monthly totals, never a historical series.
/// The exact labeled amounts remain the accessible alternative to the bars.
class OverviewMonthlyFlow extends StatelessWidget {
  const OverviewMonthlyFlow({
    super.key,
    required this.summary,
    required this.hidden,
  });

  final OverviewCurrencySummary summary;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final income = summary.projectedMonthlyIncome;
    final expense = summary.projectedMonthlyExpenses;
    final largest = math.max(income.minorUnits, expense.minorUnits);
    Widget lane(bool incoming) => _FlowLane(
      key: ValueKey(
        '${summary.currency.code}-${incoming ? 'income' : 'expense'}',
      ),
      amount: incoming ? income : expense,
      incoming: incoming,
      hidden: hidden,
      fraction: largest <= 0
          ? 0
          : ((incoming ? income : expense).minorUnits / largest).clamp(
              0.0,
              1.0,
            ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 320 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3;
        if (stacked) {
          return Column(
            children: [
              lane(true),
              const SizedBox(height: PollarSpacing.x3),
              lane(false),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: lane(true)),
            const SizedBox(width: PollarSpacing.x6),
            Expanded(child: lane(false)),
          ],
        );
      },
    );
  }
}

class _FlowLane extends StatelessWidget {
  const _FlowLane({
    super.key,
    required this.amount,
    required this.incoming,
    required this.hidden,
    required this.fraction,
  });
  final Money amount;
  final bool incoming;
  final bool hidden;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final palette = context.pollar;
    final color = incoming ? palette.success : palette.danger;
    final label = incoming ? 'Entradas' : 'Saídas';
    Widget fill(double value) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        key: ValueKey('overview-flow-fill-$label'),
        widthFactor: value,
        heightFactor: 1,
        child: ColoredBox(color: color),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              incoming ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
              size: 16,
              color: color,
            ),
            const SizedBox(width: PollarSpacing.x2),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
        const SizedBox(height: PollarSpacing.x2),
        PrivacyAmount(
          amount,
          hidden: hidden,
          semantic: incoming ? MoneySemantic.income : MoneySemantic.expense,
          showSign: incoming,
          colorBySign: incoming,
          allowWrap: true,
          reserveLayout: true,
        ),
        const SizedBox(height: PollarSpacing.x3),
        ExcludeSemantics(
          child: SizedBox(
            height: PollarSpacing.x2,
            child: ColoredBox(
              color: palette.surfaceAlt,
              child: hidden
                  ? const SizedBox.expand(key: Key('overview-flow-hidden'))
                  : PollarMotion.reduced(context)
                  ? fill(fraction)
                  : TweenAnimationBuilder<double>(
                      key: ValueKey('overview-flow-$label'),
                      tween: Tween(begin: 0, end: fraction),
                      duration: PollarMotion.focal,
                      curve: PollarMotion.curve,
                      builder: (context, value, child) => fill(value),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

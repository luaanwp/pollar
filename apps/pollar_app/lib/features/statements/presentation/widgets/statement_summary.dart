import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/pollar_theme.dart';
import '../../../../core/money/money.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../shared/presentation/money_text.dart';
import '../../../../shared/presentation/pollar_button.dart';
import '../../../../shared/presentation/pollar_card.dart';
import '../../../../shared/presentation/pollar_credit_surface.dart';
import '../../../../shared/presentation/pollar_motion.dart';
import '../../../../shared/presentation/privacy_amount.dart';
import '../../../../shared/presentation/status_badge.dart';
import '../../domain/card_statement.dart';
import '../statement_presentation.dart';

class StatementSummary extends StatelessWidget {
  const StatementSummary({
    super.key,
    required this.snapshot,
    required this.privacyHidden,
    required this.onPay,
  });

  final CardStatementSnapshot snapshot;
  final bool privacyHidden;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final statement = snapshot.statement;
    final date = DateFormat('d MMM y', 'pt_BR');
    final range =
        '${date.format(statement.periodStart)}–${date.format(statement.closingDate)}';
    return PollarCard(
      padding: PollarCardPadding.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(PollarSpacing.x5),
            child: Wrap(
              spacing: PollarSpacing.x3,
              runSpacing: PollarSpacing.x2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusBadge(
                  label: statement.status.label,
                  tone: statement.status.tone,
                  icon: statement.status.icon,
                ),
                Text(
                  range,
                  style: PollarTypography.tabular(
                    Theme.of(context).textTheme.bodySmall!,
                  ).copyWith(color: context.pollar.textSecondary),
                ),
              ],
            ),
          ),
          PollarCreditSurface(
            borderRadius: BorderRadius.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Saldo da fatura',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: context.pollar.creditForeground),
                ),
                const SizedBox(height: PollarSpacing.x2),
                PrivacyAmount(
                  statement.outstanding,
                  hidden: privacyHidden,
                  style: PollarTypography.balanceHeroCompact,
                  semantic: MoneySemantic.debt,
                  allowWrap: true,
                  reserveLayout: true,
                ),
                const SizedBox(height: PollarSpacing.x1),
                Text(
                  'Vence em ${date.format(statement.dueDate)}',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: context.pollar.creditSecondary),
                ),
                if (statement.pendingPayments.isPositive) ...[
                  const SizedBox(height: PollarSpacing.x3),
                  Wrap(
                    spacing: PollarSpacing.x2,
                    runSpacing: PollarSpacing.x1,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Pagamento pendente',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: context.pollar.creditSecondary),
                      ),
                      PrivacyAmount(
                        statement.pendingPayments,
                        hidden: privacyHidden,
                        style: Theme.of(context).textTheme.bodySmall,
                        semantic: MoneySemantic.neutral,
                        allowWrap: true,
                        reserveLayout: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: PollarSpacing.x1),
                  Wrap(
                    spacing: PollarSpacing.x2,
                    runSpacing: PollarSpacing.x1,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Disponível para pagar',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: context.pollar.creditSecondary),
                      ),
                      PrivacyAmount(
                        statement.availableToPay,
                        hidden: privacyHidden,
                        style: Theme.of(context).textTheme.bodySmall,
                        semantic: MoneySemantic.neutral,
                        allowWrap: true,
                        reserveLayout: true,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(PollarSpacing.x5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final accessible =
                        MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
                        !_fitsSummaryRow(context, constraints.maxWidth, [
                          statement.total,
                          statement.paid,
                          snapshot.availableLimit,
                        ]);
                    return accessible
                        ? Column(
                            children: [
                              _SummaryValue(
                                label: 'Total',
                                amount: statement.total,
                                hidden: privacyHidden,
                              ),
                              const SizedBox(height: PollarSpacing.x3),
                              _SummaryValue(
                                label: 'Pago',
                                amount: statement.paid,
                                hidden: privacyHidden,
                              ),
                              const SizedBox(height: PollarSpacing.x3),
                              _SummaryValue(
                                label: 'Limite disponível',
                                amount: snapshot.availableLimit,
                                hidden: privacyHidden,
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _SummaryValue(
                                  label: 'Total',
                                  amount: statement.total,
                                  hidden: privacyHidden,
                                ),
                              ),
                              Expanded(
                                child: _SummaryValue(
                                  label: 'Pago',
                                  amount: statement.paid,
                                  hidden: privacyHidden,
                                ),
                              ),
                              Expanded(
                                child: _SummaryValue(
                                  label: 'Limite disponível',
                                  amount: snapshot.availableLimit,
                                  hidden: privacyHidden,
                                ),
                              ),
                            ],
                          );
                  },
                ),
                const SizedBox(height: PollarSpacing.x4),
                Semantics(
                  container: true,
                  excludeSemantics: true,
                  label: privacyHidden
                      ? 'Limite utilizado oculto'
                      : 'Limite utilizado, ${snapshot.utilizationPercent} por cento',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Limite utilizado',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: context.pollar.textSecondary,
                                  ),
                            ),
                          ),
                          ExcludeSemantics(
                            child: Text(
                              privacyHidden
                                  ? '••%'
                                  : '${snapshot.utilizationPercent}%',
                              style: PollarTypography.tabular(
                                Theme.of(context).textTheme.labelMedium!,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: PollarSpacing.x2),
                      ExcludeSemantics(
                        child: _LimitUsage(
                          fraction: (snapshot.utilizationPercent / 100).clamp(
                            0.0,
                            1.0,
                          ),
                          hidden: privacyHidden,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onPay != null) ...[
                  const SizedBox(height: PollarSpacing.x5),
                  PollarButton(
                    label: statement.paid.isPositive
                        ? 'Registrar pagamento'
                        : 'Pagar fatura',
                    leadingIcon: LucideIcons.check,
                    fullWidth: true,
                    adaptiveHeight: true,
                    onPressed: onPay,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The same visible/masked measurements choose both privacy layouts. A narrow
/// column must not split a number that would fit intact in the full panel.
bool _fitsSummaryRow(BuildContext context, double width, List<Money> amounts) {
  final painter = TextPainter(
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  );
  try {
    for (final amount in amounts) {
      painter.text = TextSpan(
        text: const MoneyFormatter.ptBr().format(amount),
        style: PollarTypography.amountStandard,
      );
      painter.layout();
      if (painter.width > width / 3) return false;
      painter.text = TextSpan(
        text: '${amount.currency.symbol} ••••••',
        style: PollarTypography.amountStandard.copyWith(letterSpacing: 0.64),
      );
      painter.layout();
      if (painter.width > width / 3) return false;
    }
    return true;
  } finally {
    painter.dispose();
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.label,
    required this.amount,
    required this.hidden,
  });
  final String label;
  final Money amount;
  final bool hidden;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: context.pollar.textMuted),
      ),
      const SizedBox(height: PollarSpacing.x1),
      PrivacyAmount(
        amount,
        hidden: hidden,
        semantic: MoneySemantic.neutral,
        allowWrap: true,
        reserveLayout: true,
      ),
    ],
  );
}

class _LimitUsage extends StatelessWidget {
  const _LimitUsage({required this.fraction, required this.hidden});
  final double fraction;
  final bool hidden;
  @override
  Widget build(BuildContext context) {
    Widget bar(double value) => LinearProgressIndicator(
      key: const Key('statement-limit-fill'),
      value: value,
      minHeight: 6,
      borderRadius: BorderRadius.circular(PollarRadii.small),
      backgroundColor: context.pollar.surfaceAlt,
      color: context.pollar.info,
    );
    if (hidden) {
      return SizedBox(
        height: 6,
        key: const Key('statement-limit-hidden'),
        child: ColoredBox(color: context.pollar.surfaceAlt),
      );
    }
    if (PollarMotion.reduced(context)) return bar(fraction);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction),
      duration: PollarMotion.focal,
      curve: PollarMotion.curve,
      builder: (context, value, _) => bar(value),
    );
  }
}

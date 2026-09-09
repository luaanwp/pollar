import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/pollar_theme.dart';
import '../../../../core/money/money.dart';
import '../../../../shared/presentation/money_text.dart';
import '../../../../shared/presentation/pollar_button.dart';
import '../../../../shared/presentation/pollar_card.dart';
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
    final accessible = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return PollarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
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
          const SizedBox(height: PollarSpacing.x5),
          Text(
            'Saldo da fatura',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: PollarSpacing.x2),
          PrivacyAmount(
            statement.outstanding,
            hidden: privacyHidden,
            style: PollarTypography.amountHero,
            semantic: MoneySemantic.debt,
          ),
          const SizedBox(height: PollarSpacing.x1),
          Text(
            'Vence em ${date.format(statement.dueDate)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: statement.status == CardStatementStatus.overdue
                  ? context.pollar.danger
                  : context.pollar.textSecondary,
            ),
          ),
          const SizedBox(height: PollarSpacing.x5),
          if (accessible)
            Column(
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
          else
            Row(
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
            ),
          const SizedBox(height: PollarSpacing.x4),
          Semantics(
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
                            ?.copyWith(color: context.pollar.textSecondary),
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
                  child: LinearProgressIndicator(
                    value: (snapshot.utilizationPercent / 100).clamp(0, 1),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(PollarRadii.small),
                    backgroundColor: context.pollar.surfaceAlt,
                    color: context.pollar.info,
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
              onPressed: onPay,
            ),
          ],
        ],
      ),
    );
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
      PrivacyAmount(amount, hidden: hidden, semantic: MoneySemantic.neutral),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/pollar_theme.dart';
import '../../core/money/money.dart';
import 'privacy_amount.dart';
import 'status_badge.dart';

enum TransactionKind { expense, income, transfer, cardPayment }

/// Canonical transaction row for compact lists and contextual panels.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.amount,
    this.category,
    this.account,
    this.date,
    this.kind = TransactionKind.expense,
    this.installment,
    this.status,
    this.statusTone = PollarStatusTone.neutral,
    this.statusIcon,
    this.icon,
    this.privacyHidden = false,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final Money amount;
  final String? category;
  final String? account;
  final String? date;
  final TransactionKind kind;
  final String? installment;
  final String? status;
  final PollarStatusTone statusTone;
  final IconData? statusIcon;
  final IconData? icon;
  final bool privacyHidden;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    final metadata = [category, account].whereType<String>().join(' · ');
    final colors = _kindColors(pollar);

    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return _buildAccessibleLayout(context, pollar, metadata, colors);
    }

    return Semantics(
      button: onTap != null,
      selected: selected,
      child: Material(
        color: selected ? pollar.primarySoft : pollar.canvas,
        child: InkWell(
          onTap: onTap,
          hoverColor: pollar.surfaceAlt,
          focusColor: pollar.primarySoft,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PollarSpacing.x4,
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
                    icon ?? colors.icon,
                    size: 18,
                    color: colors.color,
                  ),
                ),
                const SizedBox(width: PollarSpacing.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (installment case final installment?) ...[
                            const SizedBox(width: PollarSpacing.x2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: pollar.surfaceAlt,
                                borderRadius: BorderRadius.circular(
                                  PollarRadii.small,
                                ),
                              ),
                              child: Text(
                                installment,
                                style:
                                    PollarTypography.tabular(
                                      Theme.of(context).textTheme.bodySmall!,
                                    ).copyWith(
                                      color: pollar.textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (metadata.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          metadata,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: pollar.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: PollarSpacing.x3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PrivacyAmount(
                      amount,
                      hidden: privacyHidden,
                      maskDigits: 5,
                      showSign: kind == TransactionKind.income,
                      colorBySign: kind == TransactionKind.income,
                    ),
                    if (date != null || status != null) ...[
                      const SizedBox(height: PollarSpacing.x1),
                      Wrap(
                        spacing: PollarSpacing.x2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (date case final date?)
                            Text(
                              date,
                              style: PollarTypography.tabular(
                                Theme.of(context).textTheme.bodySmall!,
                              ).copyWith(color: pollar.textMuted),
                            ),
                          if (status case final status?)
                            StatusBadge(
                              label: status,
                              tone: statusTone,
                              icon: statusIcon,
                              compact: true,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessibleLayout(
    BuildContext context,
    PollarColors pollar,
    String metadata,
    _TransactionKindColors colors,
  ) {
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: onTap != null,
      selected: selected,
      child: Material(
        color: selected ? pollar.primarySoft : pollar.canvas,
        child: InkWell(
          onTap: onTap,
          hoverColor: pollar.surfaceAlt,
          focusColor: pollar.primarySoft,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PollarSpacing.x4,
              vertical: PollarSpacing.x3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: pollar.surfaceAlt,
                        borderRadius: BorderRadius.circular(PollarRadii.medium),
                      ),
                      child: Icon(
                        icon ?? colors.icon,
                        size: 18,
                        color: colors.color,
                      ),
                    ),
                    const SizedBox(width: PollarSpacing.x3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (metadata.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              metadata,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(
                                color: pollar.textMuted,
                              ),
                            ),
                          ],
                          if (installment case final installment?) ...[
                            const SizedBox(height: PollarSpacing.x1),
                            Text(
                              installment,
                              style: PollarTypography.tabular(text.bodySmall!)
                                  .copyWith(
                                    color: pollar.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PollarSpacing.x2),
                Align(
                  alignment: Alignment.centerRight,
                  child: PrivacyAmount(
                    amount,
                    hidden: privacyHidden,
                    maskDigits: 5,
                    showSign: kind == TransactionKind.income,
                    colorBySign: kind == TransactionKind.income,
                  ),
                ),
                if (date != null || status != null) ...[
                  const SizedBox(height: PollarSpacing.x1),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: PollarSpacing.x2,
                    runSpacing: PollarSpacing.x1,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (date case final date?)
                        Text(
                          date,
                          style: PollarTypography.tabular(text.bodySmall!)
                              .copyWith(color: pollar.textMuted),
                        ),
                      if (status case final status?)
                        StatusBadge(
                          label: status,
                          tone: statusTone,
                          icon: statusIcon,
                          compact: true,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _TransactionKindColors _kindColors(PollarColors colors) => switch (kind) {
    TransactionKind.expense => _TransactionKindColors(
      LucideIcons.arrowDownLeft,
      colors.textSecondary,
    ),
    TransactionKind.income => _TransactionKindColors(
      LucideIcons.arrowUpRight,
      colors.success,
    ),
    TransactionKind.transfer => _TransactionKindColors(
      LucideIcons.arrowLeftRight,
      colors.info,
    ),
    TransactionKind.cardPayment => _TransactionKindColors(
      LucideIcons.creditCard,
      colors.info,
    ),
  };
}

class _TransactionKindColors {
  const _TransactionKindColors(this.icon, this.color);

  final IconData icon;
  final Color color;
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/pollar_theme.dart';
import '../../../../shared/presentation/money_text.dart';
import '../../../../shared/presentation/pollar_card.dart';
import '../../../../shared/presentation/privacy_amount.dart';
import '../../../../shared/presentation/status_badge.dart';
import '../../domain/card_statement.dart';

class FutureInstallmentsCard extends StatelessWidget {
  const FutureInstallmentsCard({
    super.key,
    required this.items,
    required this.privacyHidden,
  });
  final List<FutureInstallment> items;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) {
    final shown = items;
    final accessible = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final total = items.isEmpty
        ? null
        : items
              .skip(1)
              .fold(items.first.amount, (sum, item) => sum + item.amount);
    return PollarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Parcelas futuras',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: PollarSpacing.x4),
          if (shown.isEmpty)
            Text(
              'Nenhuma parcela futura registrada.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.pollar.textSecondary),
            )
          else
            for (final item in shown) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('MMM y', 'pt_BR').format(item.date),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.pollar.textMuted),
                  ),
                  const SizedBox(height: PollarSpacing.x2),
                  if (accessible)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: StatusBadge(
                            label: '${item.number}/${item.count}',
                            icon: LucideIcons.layers3,
                            compact: true,
                          ),
                        ),
                        const SizedBox(height: PollarSpacing.x2),
                        Align(
                          alignment: Alignment.centerRight,
                          child: PrivacyAmount(
                            item.amount,
                            hidden: privacyHidden,
                            semantic: MoneySemantic.debt,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        StatusBadge(
                          label: '${item.number}/${item.count}',
                          icon: LucideIcons.layers3,
                          compact: true,
                        ),
                        const Spacer(),
                        PrivacyAmount(
                          item.amount,
                          hidden: privacyHidden,
                          semantic: MoneySemantic.debt,
                        ),
                      ],
                    ),
                ],
              ),
              if (item != shown.last) const SizedBox(height: PollarSpacing.x3),
            ],
          if (total != null) ...[
            const SizedBox(height: PollarSpacing.x4),
            Divider(height: 1, color: context.pollar.border),
            const SizedBox(height: PollarSpacing.x3),
            if (accessible)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Comprometido nos próximos meses',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.pollar.textSecondary),
                  ),
                  const SizedBox(height: PollarSpacing.x2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: PrivacyAmount(
                      total,
                      hidden: privacyHidden,
                      semantic: MoneySemantic.debt,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Comprometido nos próximos meses',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: context.pollar.textSecondary),
                    ),
                  ),
                  const SizedBox(width: PollarSpacing.x3),
                  PrivacyAmount(
                    total,
                    hidden: privacyHidden,
                    semantic: MoneySemantic.debt,
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/pollar_theme.dart';
import '../../../../core/money/money.dart';
import '../../../../shared/presentation/money_text.dart';
import '../../../../shared/presentation/pollar_card.dart';
import '../../../../shared/presentation/privacy_amount.dart';
import '../../../../shared/presentation/status_badge.dart';
import '../../domain/card_statement.dart';

class StatementPurchases extends StatelessWidget {
  const StatementPurchases({
    super.key,
    required this.items,
    required this.privacyHidden,
  });
  final List<StatementPurchase> items;
  final bool privacyHidden;

  @override
  Widget build(BuildContext context) => PollarCard(
    padding: PollarCardPadding.none,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(PollarSpacing.x5),
          child: Text(
            'Compras da fatura',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PollarSpacing.x5,
              0,
              PollarSpacing.x5,
              PollarSpacing.x5,
            ),
            child: Text(
              'Nenhuma compra foi atribuída a este ciclo.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.pollar.textSecondary),
            ),
          )
        else
          for (final group in _groups(items)) ...[
            _DayHeader(group: group, hidden: privacyHidden),
            for (final item in group.items)
              _PurchaseRow(item: item, hidden: privacyHidden),
          ],
      ],
    ),
  );

  List<_PurchaseGroup> _groups(List<StatementPurchase> source) {
    final map = <DateTime, List<StatementPurchase>>{};
    for (final item in source) {
      map
          .putIfAbsent(
            DateTime(item.date.year, item.date.month, item.date.day),
            () => [],
          )
          .add(item);
    }
    return [
      for (final entry in map.entries) _PurchaseGroup(entry.key, entry.value),
    ];
  }
}

class _PurchaseGroup {
  _PurchaseGroup(this.date, this.items);
  final DateTime date;
  final List<StatementPurchase> items;
  Money get total =>
      items.skip(1).fold(items.first.amount, (sum, item) => sum + item.amount);
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.group, required this.hidden});
  final _PurchaseGroup group;
  final bool hidden;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: PollarSpacing.x5,
      vertical: PollarSpacing.x2,
    ),
    decoration: BoxDecoration(
      color: context.pollar.surfaceAlt,
      border: Border.symmetric(
        horizontal: BorderSide(color: context.pollar.border),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            DateFormat("d 'de' MMMM", 'pt_BR').format(group.date),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        PrivacyAmount(
          group.total,
          hidden: hidden,
          style: Theme.of(context).textTheme.labelMedium,
          semantic: MoneySemantic.expense,
        ),
      ],
    ),
  );
}

class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({required this.item, required this.hidden});
  final StatementPurchase item;
  final bool hidden;
  @override
  Widget build(BuildContext context) {
    final accessible = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final identity = Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: context.pollar.infoSoft,
            borderRadius: BorderRadius.circular(PollarRadii.medium),
          ),
          child: Icon(
            LucideIcons.shoppingBag,
            size: 18,
            color: context.pollar.info,
          ),
        ),
        const SizedBox(width: PollarSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: PollarSpacing.x1),
              Wrap(
                spacing: PollarSpacing.x2,
                runSpacing: PollarSpacing.x1,
                children: [
                  Text(
                    item.category ?? 'Sem categoria',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.pollar.textSecondary),
                  ),
                  if (item.isInstallment)
                    StatusBadge(
                      label:
                          '${item.installmentNumber}/${item.installmentCount}',
                      icon: LucideIcons.layers3,
                      compact: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
    final amount = PrivacyAmount(
      -item.amount,
      hidden: hidden,
      semantic: MoneySemantic.expense,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PollarSpacing.x5,
        vertical: PollarSpacing.x3,
      ),
      child: accessible
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                identity,
                const SizedBox(height: PollarSpacing.x2),
                Align(alignment: Alignment.centerRight, child: amount),
              ],
            )
          : Row(
              children: [
                Expanded(child: identity),
                const SizedBox(width: PollarSpacing.x3),
                amount,
              ],
            ),
    );
  }
}

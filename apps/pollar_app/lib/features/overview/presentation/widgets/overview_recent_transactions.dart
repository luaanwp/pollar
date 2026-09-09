import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/pollar_theme.dart';
import '../../../../shared/presentation/pollar_button.dart';
import '../../../../shared/presentation/pollar_card.dart';
import '../../../../shared/presentation/transaction_tile.dart';
import '../../domain/overview_snapshot.dart';
import '../overview_presentation.dart';

class OverviewRecentTransactions extends StatelessWidget {
  const OverviewRecentTransactions({
    super.key,
    required this.transactions,
    required this.privacyHidden,
    required this.onOpenTransactions,
  });

  final List<OverviewRecentTransaction> transactions;
  final bool privacyHidden;
  final VoidCallback onOpenTransactions;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    final accessible = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final title = Text(
      'Transações recentes',
      style: Theme.of(context).textTheme.titleMedium,
    );
    final action = PollarButton(
      label: 'Ver transações',
      trailingIcon: LucideIcons.arrowRight,
      variant: PollarButtonVariant.ghost,
      size: PollarControlSize.compact,
      onPressed: onOpenTransactions,
    );
    return PollarCard(
      padding: PollarCardPadding.none,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PollarSpacing.x4,
              PollarSpacing.x3,
              PollarSpacing.x2,
              PollarSpacing.x3,
            ),
            child: accessible
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      title,
                      const SizedBox(height: PollarSpacing.x2),
                      Align(alignment: Alignment.centerRight, child: action),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: title),
                      action,
                    ],
                  ),
          ),
          Divider(height: 1, color: pollar.border),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(PollarSpacing.x5),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.receiptText,
                    size: 24,
                    color: pollar.textMuted,
                  ),
                  const SizedBox(height: PollarSpacing.x2),
                  Text(
                    'Nenhuma transação registrada',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: PollarSpacing.x1),
                  Text(
                    'O saldo inicial já compõe sua posição. Novos lançamentos aparecerão aqui.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: pollar.textSecondary),
                  ),
                ],
              ),
            )
          else
            for (final (index, transaction) in transactions.indexed) ...[
              if (index > 0) Divider(height: 1, color: pollar.border),
              TransactionTile(
                title: transaction.description,
                category: transaction.category,
                account: transaction.accountLabel,
                date: _shortDate(transaction.occurredAt),
                amount: transaction.displayAmount,
                kind: transaction.type.overviewKind,
                status: transaction.status.overviewLabel,
                statusTone: transaction.status.overviewTone,
                statusIcon: transaction.status.overviewIcon,
                privacyHidden: privacyHidden,
                onTap: onOpenTransactions,
              ),
            ],
        ],
      ),
    );
  }

  String _shortDate(DateTime date) {
    const months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

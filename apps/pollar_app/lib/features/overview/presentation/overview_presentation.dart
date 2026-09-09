import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/ledger/balance_rules.dart';
import '../../../shared/presentation/status_badge.dart';
import '../../../shared/presentation/transaction_tile.dart';

extension OverviewTransactionTypePresentation on TransactionType {
  TransactionKind get overviewKind => switch (this) {
    TransactionType.income => TransactionKind.income,
    TransactionType.expense ||
    TransactionType.cardPurchase => TransactionKind.expense,
    TransactionType.transfer => TransactionKind.transfer,
    TransactionType.cardStatementPayment => TransactionKind.cardPayment,
  };
}

extension OverviewTransactionStatusPresentation on TransactionStatus {
  String get overviewLabel => switch (this) {
    TransactionStatus.previsto => 'Previsto',
    TransactionStatus.pendente => 'Pendente',
    TransactionStatus.compensado => 'Compensado',
    TransactionStatus.conciliado => 'Conciliado',
    TransactionStatus.cancelado => 'Cancelado',
  };

  PollarStatusTone get overviewTone => switch (this) {
    TransactionStatus.previsto => PollarStatusTone.neutral,
    TransactionStatus.pendente => PollarStatusTone.warning,
    TransactionStatus.compensado => PollarStatusTone.success,
    TransactionStatus.conciliado => PollarStatusTone.info,
    TransactionStatus.cancelado => PollarStatusTone.danger,
  };

  IconData get overviewIcon => switch (this) {
    TransactionStatus.previsto ||
    TransactionStatus.pendente => LucideIcons.clock,
    TransactionStatus.compensado ||
    TransactionStatus.conciliado => LucideIcons.check,
    TransactionStatus.cancelado => LucideIcons.x,
  };
}

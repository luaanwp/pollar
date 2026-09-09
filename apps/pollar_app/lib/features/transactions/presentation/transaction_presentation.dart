import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/ledger/balance_rules.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/status_badge.dart';
import '../../../shared/presentation/transaction_tile.dart';
import '../domain/financial_transaction.dart';

extension TransactionTypePresentation on TransactionType {
  String get label => switch (this) {
    TransactionType.income => 'Receita',
    TransactionType.expense => 'Despesa',
    TransactionType.transfer => 'Transferência',
    TransactionType.cardPurchase => 'Compra no cartão',
    TransactionType.cardStatementPayment => 'Pagamento de fatura',
  };

  TransactionKind get kind => switch (this) {
    TransactionType.income => TransactionKind.income,
    TransactionType.expense ||
    TransactionType.cardPurchase => TransactionKind.expense,
    TransactionType.transfer => TransactionKind.transfer,
    TransactionType.cardStatementPayment => TransactionKind.cardPayment,
  };
}

extension TransactionStatusPresentation on TransactionStatus {
  String get label => switch (this) {
    TransactionStatus.previsto => 'Previsto',
    TransactionStatus.pendente => 'Pendente',
    TransactionStatus.compensado => 'Compensado',
    TransactionStatus.conciliado => 'Conciliado',
    TransactionStatus.cancelado => 'Cancelado',
  };

  PollarStatusTone get tone => switch (this) {
    TransactionStatus.previsto => PollarStatusTone.neutral,
    TransactionStatus.pendente => PollarStatusTone.warning,
    TransactionStatus.compensado => PollarStatusTone.success,
    TransactionStatus.conciliado => PollarStatusTone.info,
    TransactionStatus.cancelado => PollarStatusTone.danger,
  };

  IconData get icon => switch (this) {
    TransactionStatus.previsto ||
    TransactionStatus.pendente => LucideIcons.clock,
    TransactionStatus.compensado ||
    TransactionStatus.conciliado => LucideIcons.check,
    TransactionStatus.cancelado => LucideIcons.x,
  };
}

extension FinancialTransactionPresentation on FinancialTransaction {
  Money get displayAmount => postings.first.signedAmount;
}

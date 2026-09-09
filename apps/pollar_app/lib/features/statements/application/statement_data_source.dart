import '../../../core/ledger/balance_rules.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

class StatementAccountRecord {
  const StatementAccountRecord({
    required this.id,
    required this.name,
    required this.currency,
    required this.openingBalance,
    required this.isCreditCard,
    required this.isArchived,
    this.creditLimit,
    this.closingDay,
    this.dueDay,
  });

  final String id;
  final String name;
  final Currency currency;
  final Money openingBalance;
  final bool isCreditCard;
  final bool isArchived;
  final Money? creditLimit;
  final int? closingDay;
  final int? dueDay;
}

class StatementTransactionRecord {
  const StatementTransactionRecord({
    required this.id,
    required this.description,
    required this.type,
    required this.status,
    required this.amount,
    required this.accountId,
    required this.occurredAt,
    this.counterAccountId,
    this.category,
    this.installmentNumber,
    this.installmentCount,
    this.purchaseTotal,
    this.statementId,
  });

  final String id;
  final String description;
  final TransactionType type;
  final TransactionStatus status;
  final Money amount;
  final String accountId;
  final String? counterAccountId;
  final DateTime occurredAt;
  final String? category;
  final int? installmentNumber;
  final int? installmentCount;
  final Money? purchaseTotal;
  final String? statementId;
}

class StatementSourceData {
  const StatementSourceData({
    required this.accounts,
    required this.transactions,
  });
  final List<StatementAccountRecord> accounts;
  final List<StatementTransactionRecord> transactions;
}

class StatementPaymentCommand {
  const StatementPaymentCommand({
    required this.id,
    required this.statementId,
    required this.cardId,
    required this.sourceAccountId,
    required this.amount,
    required this.occurredAt,
  });

  final String id;
  final String statementId;
  final String cardId;
  final String sourceAccountId;
  final Money amount;
  final DateTime occurredAt;
}

abstract interface class StatementDataSource {
  Future<StatementSourceData> load();
  Future<void> recordPayment(StatementPaymentCommand command);
}

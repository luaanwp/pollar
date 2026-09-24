import '../../../core/ledger/balance_rules.dart';
import '../../../core/ledger/posting.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

class ReportAccountRecord {
  const ReportAccountRecord({
    required this.id,
    required this.currency,
    required this.openingBalance,
    required this.isArchived,
  });

  final String id;
  final Currency currency;
  final Money openingBalance;
  final bool isArchived;
}

class ReportTransactionRecord {
  const ReportTransactionRecord({
    required this.id,
    required this.description,
    required this.type,
    required this.status,
    required this.amount,
    required this.accountId,
    required this.occurredAt,
    this.counterAccountId,
    this.category,
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

  List<Posting> get postings => postingsFor(
    type: type,
    status: status,
    amount: amount,
    accountId: accountId,
    counterAccountId: counterAccountId,
  );
}

class ReportSourceData {
  const ReportSourceData({required this.accounts, required this.transactions});

  final List<ReportAccountRecord> accounts;
  final List<ReportTransactionRecord> transactions;
}

abstract interface class ReportDataSource {
  Future<ReportSourceData> load();
}

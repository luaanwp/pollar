import '../../../core/ledger/balance_rules.dart';
import '../../../core/ledger/posting.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

enum OverviewAccountKind { asset, creditCard }

class OverviewAccountRecord {
  const OverviewAccountRecord({
    required this.id,
    required this.name,
    required this.currency,
    required this.openingBalance,
    required this.kind,
    required this.isArchived,
  });

  final String id;
  final String name;
  final Currency currency;
  final Money openingBalance;
  final OverviewAccountKind kind;
  final bool isArchived;
}

class OverviewTransactionRecord {
  const OverviewTransactionRecord({
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

class OverviewSourceData {
  const OverviewSourceData({
    required this.accounts,
    required this.transactions,
  });

  final List<OverviewAccountRecord> accounts;
  final List<OverviewTransactionRecord> transactions;
}

/// Cross-feature read boundary consumed by the overview application layer.
abstract interface class OverviewDataSource {
  Future<OverviewSourceData> load();
}

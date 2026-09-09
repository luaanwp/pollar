import 'package:meta/meta.dart';

import '../../../core/ledger/balance_rules.dart';
import '../../../core/ledger/posting.dart';
import '../../../core/money/money.dart';

@immutable
class FinancialTransaction {
  factory FinancialTransaction({
    required String id,
    required String description,
    required TransactionType type,
    required TransactionStatus status,
    required Money amount,
    required String accountId,
    required DateTime occurredAt,
    String? counterAccountId,
    String? category,
    String? note,
  }) {
    final normalizedId = id.trim();
    final normalizedDescription = description.trim();
    final normalizedAccountId = accountId.trim();
    final normalizedCounter = _optional(counterAccountId);
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Transaction id cannot be empty');
    }
    if (normalizedDescription.isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'Transaction description cannot be empty',
      );
    }
    if (normalizedAccountId.isEmpty) {
      throw ArgumentError.value(
        accountId,
        'accountId',
        'Account id cannot be empty',
      );
    }

    postingsFor(
      type: type,
      status: status,
      amount: amount,
      accountId: normalizedAccountId,
      counterAccountId: normalizedCounter,
    );

    return FinancialTransaction._(
      id: normalizedId,
      description: normalizedDescription,
      type: type,
      status: status,
      amount: amount,
      accountId: normalizedAccountId,
      counterAccountId: normalizedCounter,
      occurredAt: occurredAt,
      category: _optional(category),
      note: _optional(note),
    );
  }

  const FinancialTransaction._({
    required this.id,
    required this.description,
    required this.type,
    required this.status,
    required this.amount,
    required this.accountId,
    required this.occurredAt,
    this.counterAccountId,
    this.category,
    this.note,
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
  final String? note;

  List<Posting> get postings => postingsFor(
    type: type,
    status: status,
    amount: amount,
    accountId: accountId,
    counterAccountId: counterAccountId,
  );

  bool get isCanceled => status == TransactionStatus.cancelado;

  FinancialTransaction cancel() => _withStatus(TransactionStatus.cancelado);

  FinancialTransaction _withStatus(TransactionStatus value) =>
      FinancialTransaction(
        id: id,
        description: description,
        type: type,
        status: value,
        amount: amount,
        accountId: accountId,
        counterAccountId: counterAccountId,
        occurredAt: occurredAt,
        category: category,
        note: note,
      );

  static String? _optional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  @override
  bool operator ==(Object other) =>
      other is FinancialTransaction &&
      other.id == id &&
      other.description == description &&
      other.type == type &&
      other.status == status &&
      other.amount == amount &&
      other.accountId == accountId &&
      other.counterAccountId == counterAccountId &&
      other.occurredAt == occurredAt &&
      other.category == category &&
      other.note == note;

  @override
  int get hashCode => Object.hash(
    id,
    description,
    type,
    status,
    amount,
    accountId,
    counterAccountId,
    occurredAt,
    category,
    note,
  );
}

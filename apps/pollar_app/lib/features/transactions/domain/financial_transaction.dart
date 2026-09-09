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
    String? installmentGroupId,
    int? installmentNumber,
    int? installmentCount,
    Money? purchaseTotal,
    String? statementId,
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
    final normalizedInstallmentGroup = _optional(installmentGroupId);
    final hasInstallmentMetadata =
        normalizedInstallmentGroup != null ||
        installmentNumber != null ||
        installmentCount != null ||
        purchaseTotal != null;
    if (hasInstallmentMetadata) {
      if (type != TransactionType.cardPurchase ||
          normalizedInstallmentGroup == null ||
          installmentNumber == null ||
          installmentCount == null ||
          purchaseTotal == null) {
        throw ArgumentError(
          'Installment metadata is complete and exclusive to card purchases',
        );
      }
      if (installmentCount < 2 ||
          installmentCount > 360 ||
          installmentNumber < 1 ||
          installmentNumber > installmentCount) {
        throw RangeError('Invalid installment position');
      }
      if (!purchaseTotal.isPositive ||
          purchaseTotal.currency != amount.currency) {
        throw ArgumentError(
          'Purchase total must be positive and use the purchase currency',
        );
      }
    }
    final normalizedStatementId = _optional(statementId);
    if (normalizedStatementId != null &&
        type != TransactionType.cardStatementPayment) {
      throw ArgumentError('Only statement payments may reference a statement');
    }

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
      installmentGroupId: normalizedInstallmentGroup,
      installmentNumber: installmentNumber,
      installmentCount: installmentCount,
      purchaseTotal: purchaseTotal,
      statementId: normalizedStatementId,
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
    this.installmentGroupId,
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
  final String? note;
  final String? installmentGroupId;
  final int? installmentNumber;
  final int? installmentCount;
  final Money? purchaseTotal;
  final String? statementId;

  bool get isInstallment => installmentGroupId != null;

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
        installmentGroupId: installmentGroupId,
        installmentNumber: installmentNumber,
        installmentCount: installmentCount,
        purchaseTotal: purchaseTotal,
        statementId: statementId,
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
      other.note == note &&
      other.installmentGroupId == installmentGroupId &&
      other.installmentNumber == installmentNumber &&
      other.installmentCount == installmentCount &&
      other.purchaseTotal == purchaseTotal &&
      other.statementId == statementId;

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
    installmentGroupId,
    installmentNumber,
    installmentCount,
    purchaseTotal,
    statementId,
  );
}

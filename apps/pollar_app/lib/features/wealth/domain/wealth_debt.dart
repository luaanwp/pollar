import '../../../core/money/money.dart';

enum WealthDebtKind { loan, financing, personal, other }

class WealthDebt {
  WealthDebt({
    required this.id,
    required String name,
    required this.kind,
    required this.originalAmount,
    required this.outstandingAmount,
    required this.updatedAt,
    this.annualInterestBasisPoints = 0,
    this.dueDate,
    this.active = true,
  }) : name = name.trim() {
    if (id.trim().isEmpty || this.name.isEmpty) {
      throw ArgumentError('Debt identity cannot be empty.');
    }
    if (!originalAmount.isPositive || outstandingAmount.isNegative) {
      throw ArgumentError('Debt amounts must be positive magnitudes.');
    }
    if (originalAmount.currency != outstandingAmount.currency) {
      throw ArgumentError('Debt amounts must use the same currency.');
    }
    if (annualInterestBasisPoints < 0 || annualInterestBasisPoints > 100000) {
      throw ArgumentError('Interest must be between 0% and 1000%.');
    }
  }

  final String id;
  final String name;
  final WealthDebtKind kind;
  final Money originalAmount;
  final Money outstandingAmount;
  final int annualInterestBasisPoints;
  final DateTime? dueDate;
  final DateTime updatedAt;
  final bool active;

  bool get settled => outstandingAmount.isZero;

  WealthDebt copyWith({
    Money? outstandingAmount,
    DateTime? updatedAt,
    bool? active,
  }) => WealthDebt(
    id: id,
    name: name,
    kind: kind,
    originalAmount: originalAmount,
    outstandingAmount: outstandingAmount ?? this.outstandingAmount,
    annualInterestBasisPoints: annualInterestBasisPoints,
    dueDate: dueDate,
    updatedAt: updatedAt ?? this.updatedAt,
    active: active ?? this.active,
  );
}

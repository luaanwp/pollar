import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

enum PlanningMovementKind { income, expense, cardPurchase, neutral }

class PlanningLedgerRecord {
  const PlanningLedgerRecord({
    required this.occurredAt,
    required this.amount,
    required this.kind,
    required this.canceled,
    this.category,
  });

  final DateTime occurredAt;
  final Money amount;
  final PlanningMovementKind kind;
  final bool canceled;
  final String? category;
}

class PlanningAccountReference {
  const PlanningAccountReference({
    required this.id,
    required this.name,
    required this.currency,
    required this.active,
  });

  final String id;
  final String name;
  final Currency currency;
  final bool active;
}

abstract interface class PlanningLedgerSource {
  Future<List<PlanningLedgerRecord>> listMovements();

  Future<List<PlanningAccountReference>> listAccounts();
}

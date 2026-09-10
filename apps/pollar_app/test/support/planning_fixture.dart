import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/planning/application/planning_ledger_source.dart';
import 'package:pollar_app/features/planning/data/in_memory_planning_repository.dart';
import 'package:pollar_app/features/planning/domain/budget.dart';
import 'package:pollar_app/features/planning/domain/recurring_rule.dart';

final planningFixtureNow = DateTime(2026, 9, 9);

Money _brl(int minor) => Money(minorUnits: minor, currency: Currency.brl);

InMemoryPlanningRepository createPlanningFixtureRepository() =>
    InMemoryPlanningRepository(
      budgets: [
        Budget(
          id: 'food-budget',
          category: 'Alimentação',
          month: DateTime(2026, 9),
          limit: _brl(70000),
        ),
        Budget(
          id: 'transport-budget',
          category: 'Transporte',
          month: DateTime(2026, 9),
          limit: _brl(30000),
          alertThreshold: 85,
        ),
        Budget(
          id: 'leisure-budget',
          category: 'Lazer',
          month: DateTime(2026, 9),
          limit: _brl(20000),
          active: false,
        ),
      ],
      recurringRules: [
        RecurringRule(
          id: 'salary',
          description: 'Salário',
          kind: RecurringKind.income,
          frequency: RecurrenceFrequency.monthly,
          amount: _brl(500000),
          accountId: 'bank',
          category: 'Renda',
          firstDueDate: DateTime(2026, 1, 5),
          remindDaysBefore: 2,
        ),
        RecurringRule(
          id: 'rent',
          description: 'Aluguel',
          kind: RecurringKind.expense,
          frequency: RecurrenceFrequency.monthly,
          amount: _brl(180000),
          accountId: 'bank',
          category: 'Moradia',
          firstDueDate: DateTime(2026, 1, 10),
          remindDaysBefore: 3,
        ),
        RecurringRule(
          id: 'streaming',
          description: 'Streaming',
          kind: RecurringKind.subscription,
          frequency: RecurrenceFrequency.monthly,
          amount: _brl(3990),
          accountId: 'card',
          category: 'Assinaturas',
          firstDueDate: DateTime(2026, 1, 12),
          remindDaysBefore: 3,
        ),
        RecurringRule(
          id: 'electricity',
          description: 'Energia elétrica',
          kind: RecurringKind.expense,
          frequency: RecurrenceFrequency.monthly,
          amount: _brl(22000),
          accountId: 'bank',
          category: 'Moradia',
          firstDueDate: DateTime(2026, 1, 15),
          remindDaysBefore: 4,
        ),
        RecurringRule(
          id: 'insurance',
          description: 'Seguro residencial',
          kind: RecurringKind.expense,
          frequency: RecurrenceFrequency.monthly,
          amount: _brl(4500),
          accountId: 'bank',
          category: 'Moradia',
          firstDueDate: DateTime(2026, 1, 22),
          remindDaysBefore: 4,
          active: false,
        ),
      ],
    );

class PlanningFixtureLedgerSource implements PlanningLedgerSource {
  const PlanningFixtureLedgerSource();

  @override
  Future<List<PlanningAccountReference>> listAccounts() async => const [
    PlanningAccountReference(
      id: 'bank',
      name: 'Conta principal',
      currency: Currency.brl,
      active: true,
    ),
    PlanningAccountReference(
      id: 'card',
      name: 'Cartão Ouro',
      currency: Currency.brl,
      active: true,
    ),
  ];

  @override
  Future<List<PlanningLedgerRecord>> listMovements() async => [
    PlanningLedgerRecord(
      occurredAt: DateTime(2026, 9, 2),
      amount: _brl(34000),
      kind: PlanningMovementKind.expense,
      canceled: false,
      category: 'Alimentação',
    ),
    PlanningLedgerRecord(
      occurredAt: DateTime(2026, 9, 7),
      amount: _brl(18000),
      kind: PlanningMovementKind.cardPurchase,
      canceled: false,
      category: 'Alimentação',
    ),
    PlanningLedgerRecord(
      occurredAt: DateTime(2026, 9, 8),
      amount: _brl(27000),
      kind: PlanningMovementKind.expense,
      canceled: false,
      category: 'Transporte',
    ),
  ];
}

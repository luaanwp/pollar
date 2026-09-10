import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/planning/application/planning_ledger_source.dart';
import 'package:pollar_app/features/planning/application/planning_service.dart';
import 'package:pollar_app/features/planning/data/in_memory_planning_repository.dart';
import 'package:pollar_app/features/planning/domain/budget.dart';
import 'package:pollar_app/features/planning/domain/recurring_rule.dart';

void main() {
  const brl = Currency.brl;

  test('reconciles budgets with real expenses and card purchases', () async {
    final repository = InMemoryPlanningRepository(
      budgets: [
        Budget(
          id: 'food',
          category: 'Alimentação',
          month: DateTime(2026, 9, 20),
          limit: const Money(minorUnits: 100000, currency: brl),
        ),
      ],
    );
    final service = PlanningService(
      repository,
      _Ledger([
        PlanningLedgerRecord(
          occurredAt: DateTime(2026, 9, 3),
          amount: const Money(minorUnits: 25000, currency: brl),
          kind: PlanningMovementKind.expense,
          canceled: false,
          category: 'Alimentação',
        ),
        PlanningLedgerRecord(
          occurredAt: DateTime(2026, 9, 8),
          amount: const Money(minorUnits: 10000, currency: brl),
          kind: PlanningMovementKind.cardPurchase,
          canceled: false,
          category: 'alimentação',
        ),
        PlanningLedgerRecord(
          occurredAt: DateTime(2026, 9, 9),
          amount: const Money(minorUnits: 99999, currency: brl),
          kind: PlanningMovementKind.expense,
          canceled: true,
          category: 'Alimentação',
        ),
      ]),
    );

    final snapshot = await service.load(
      month: DateTime(2026, 9),
      currency: brl,
      today: DateTime(2026, 9, 9),
    );

    expect(snapshot.totalBudgeted.minorUnits, 100000);
    expect(snapshot.totalSpent.minorUnits, 35000);
    expect(snapshot.budgets.single.remaining.minorUnits, 65000);
    expect(snapshot.budgets.single.percent, 35);
  });

  test('builds clamped monthly, weekly and yearly occurrences', () {
    final monthly = RecurringRule(
      id: 'monthly',
      description: 'Mensal',
      kind: RecurringKind.expense,
      frequency: RecurrenceFrequency.monthly,
      amount: const Money(minorUnits: 100, currency: brl),
      accountId: 'account',
      firstDueDate: DateTime(2026, 1, 31),
    );
    final weekly = RecurringRule(
      id: 'weekly',
      description: 'Semanal',
      kind: RecurringKind.expense,
      frequency: RecurrenceFrequency.weekly,
      amount: const Money(minorUnits: 100, currency: brl),
      accountId: 'account',
      firstDueDate: DateTime(2026, 2, 2),
    );
    final yearly = RecurringRule(
      id: 'yearly',
      description: 'Anual',
      kind: RecurringKind.subscription,
      frequency: RecurrenceFrequency.yearly,
      amount: const Money(minorUnits: 100, currency: brl),
      accountId: 'account',
      firstDueDate: DateTime(2024, 2, 29),
    );

    expect(PlanningService.occurrencesInMonth(monthly, DateTime(2026, 2)), [
      DateTime(2026, 2, 28),
    ]);
    expect(
      PlanningService.occurrencesInMonth(weekly, DateTime(2026, 2)).length,
      4,
    );
    expect(PlanningService.occurrencesInMonth(yearly, DateTime(2026, 2)), [
      DateTime(2026, 2, 28),
    ]);
  });

  test('derives reminder window and exact recurring totals', () async {
    final repository = InMemoryPlanningRepository(
      recurringRules: [
        RecurringRule(
          id: 'rent',
          description: 'Aluguel',
          kind: RecurringKind.expense,
          frequency: RecurrenceFrequency.monthly,
          amount: const Money(minorUnits: 180000, currency: brl),
          accountId: 'account',
          firstDueDate: DateTime(2026, 1, 10),
          remindDaysBefore: 3,
        ),
        RecurringRule(
          id: 'salary',
          description: 'Salário',
          kind: RecurringKind.income,
          frequency: RecurrenceFrequency.monthly,
          amount: const Money(minorUnits: 500000, currency: brl),
          accountId: 'account',
          firstDueDate: DateTime(2026, 1, 8),
          remindDaysBefore: 1,
        ),
      ],
    );
    final snapshot = await PlanningService(repository, const _Ledger([])).load(
      month: DateTime(2026, 9),
      currency: brl,
      today: DateTime(2026, 9, 8),
    );

    expect(snapshot.recurringExpenses.minorUnits, 180000);
    expect(snapshot.recurringIncome.minorUnits, 500000);
    expect(snapshot.reminders.map((item) => item.occurrence.rule.id), [
      'salary',
      'rent',
    ]);
  });

  test(
    'rejects a duplicate active category budget in the same month',
    () async {
      final repository = InMemoryPlanningRepository(
        budgets: [
          Budget(
            id: 'existing',
            category: 'Mercado',
            month: DateTime(2026, 9),
            limit: const Money(minorUnits: 10000, currency: brl),
          ),
        ],
      );
      final service = PlanningService(repository, const _Ledger([]));

      expect(
        () => service.createBudget(
          Budget(
            id: 'duplicate',
            category: 'mercado',
            month: DateTime(2026, 9),
            limit: const Money(minorUnits: 20000, currency: brl),
          ),
        ),
        throwsStateError,
      );
    },
  );
}

class _Ledger implements PlanningLedgerSource {
  const _Ledger(this.records);

  final List<PlanningLedgerRecord> records;

  @override
  Future<List<PlanningLedgerRecord>> listMovements() async => records;

  @override
  Future<List<PlanningAccountReference>> listAccounts() async => const [];
}

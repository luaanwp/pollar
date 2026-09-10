import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/planning/data/drift_planning_repository.dart';
import 'package:pollar_app/features/planning/domain/budget.dart';
import 'package:pollar_app/features/planning/domain/recurring_rule.dart';
import 'package:pollar_app/shared/data/local_database.dart';

void main() {
  late LocalDatabase database;
  late DriftPlanningRepository repository;

  setUp(() async {
    database = LocalDatabase(NativeDatabase.memory());
    repository = DriftPlanningRepository(database);
    await database
        .into(database.accountEntries)
        .insert(
          AccountEntriesCompanion.insert(
            id: 'account',
            name: 'Conta',
            type: 'checking',
            currencyCode: 'BRL',
            currencyDecimalDigits: 2,
            currencySymbol: r'R$',
            openingBalanceMinor: 0,
            status: 'active',
            creditLimitMinor: const Value(null),
            closingDay: const Value(null),
            dueDay: const Value(null),
          ),
        );
  });

  tearDown(() => database.close());

  test('round trips budgets and active state', () async {
    final budget = Budget(
      id: 'budget',
      category: 'Alimentação',
      month: DateTime(2026, 9),
      limit: const Money(minorUnits: 95000, currency: Currency.brl),
      alertThreshold: 80,
    );
    await repository.addBudget(budget);
    await repository.replaceBudget(budget.copyWith(active: false));

    final stored = (await repository.findBudgets()).single;
    expect(stored.category, 'Alimentação');
    expect(stored.limit, budget.limit);
    expect(stored.alertThreshold, 80);
    expect(stored.active, isFalse);
  });

  test('round trips recurring rules and subscription metadata', () async {
    final rule = RecurringRule(
      id: 'streaming',
      description: 'Streaming',
      kind: RecurringKind.subscription,
      frequency: RecurrenceFrequency.monthly,
      amount: const Money(minorUnits: 3990, currency: Currency.brl),
      accountId: 'account',
      category: 'Assinaturas',
      firstDueDate: DateTime(2026, 9, 12),
      remindDaysBefore: 2,
    );
    await repository.addRecurringRule(rule);

    final stored = (await repository.findRecurringRules()).single;
    expect(stored.description, 'Streaming');
    expect(stored.kind, RecurringKind.subscription);
    expect(stored.frequency, RecurrenceFrequency.monthly);
    expect(stored.amount, rule.amount);
    expect(stored.firstDueDate, DateTime(2026, 9, 12));
    expect(stored.remindDaysBefore, 2);
  });
}

import 'package:drift/drift.dart';

import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/data/local_database.dart';
import '../domain/budget.dart';
import '../domain/planning_repository.dart';
import '../domain/recurring_rule.dart';

class DriftPlanningRepository implements PlanningRepository {
  const DriftPlanningRepository(this._database);

  final LocalDatabase _database;

  @override
  Future<List<Budget>> findBudgets() async =>
      (await (_database.select(
            _database.budgetEntries,
          )..orderBy([(row) => OrderingTerm.asc(row.category)])).get())
          .map(_budgetFromStored)
          .toList(growable: false);

  @override
  Future<List<RecurringRule>> findRecurringRules() async =>
      (await (_database.select(
            _database.recurringRuleEntries,
          )..orderBy([(row) => OrderingTerm.asc(row.firstDueAtMicros)])).get())
          .map(_ruleFromStored)
          .toList(growable: false);

  @override
  Future<void> addBudget(Budget budget) => _database
      .into(_database.budgetEntries)
      .insert(_budgetToCompanion(budget));

  @override
  Future<void> replaceBudget(Budget budget) async {
    final updated =
        await (_database.update(_database.budgetEntries)
              ..where((row) => row.id.equals(budget.id)))
            .write(_budgetToCompanion(budget));
    if (updated == 0) throw StateError('Budget ${budget.id} does not exist');
  }

  @override
  Future<void> addRecurringRule(RecurringRule rule) => _database
      .into(_database.recurringRuleEntries)
      .insert(_ruleToCompanion(rule));

  @override
  Future<void> replaceRecurringRule(RecurringRule rule) async {
    final updated = await (_database.update(
      _database.recurringRuleEntries,
    )..where((row) => row.id.equals(rule.id))).write(_ruleToCompanion(rule));
    if (updated == 0) throw StateError('Rule ${rule.id} does not exist');
  }

  Budget _budgetFromStored(StoredBudget stored) {
    final currency = _currency(
      stored.currencyCode,
      stored.currencyDecimalDigits,
      stored.currencySymbol,
    );
    return Budget(
      id: stored.id,
      category: stored.category,
      month: DateTime.fromMicrosecondsSinceEpoch(stored.monthMicros),
      limit: Money(minorUnits: stored.limitMinor, currency: currency),
      alertThreshold: stored.alertThreshold,
      active: stored.active,
    );
  }

  BudgetEntriesCompanion _budgetToCompanion(Budget budget) =>
      BudgetEntriesCompanion.insert(
        id: budget.id,
        category: budget.category,
        monthMicros: budget.month.microsecondsSinceEpoch,
        limitMinor: budget.limit.minorUnits,
        currencyCode: budget.limit.currency.code,
        currencyDecimalDigits: budget.limit.currency.decimalDigits,
        currencySymbol: budget.limit.currency.symbol,
        alertThreshold: Value(budget.alertThreshold),
        active: Value(budget.active),
      );

  RecurringRule _ruleFromStored(StoredRecurringRule stored) {
    final currency = _currency(
      stored.currencyCode,
      stored.currencyDecimalDigits,
      stored.currencySymbol,
    );
    return RecurringRule(
      id: stored.id,
      description: stored.description,
      kind: RecurringKind.values.byName(stored.kind),
      frequency: RecurrenceFrequency.values.byName(stored.frequency),
      amount: Money(minorUnits: stored.amountMinor, currency: currency),
      accountId: stored.accountId,
      category: stored.category,
      firstDueDate: DateTime.fromMicrosecondsSinceEpoch(
        stored.firstDueAtMicros,
      ),
      remindDaysBefore: stored.remindDaysBefore,
      active: stored.active,
    );
  }

  RecurringRuleEntriesCompanion _ruleToCompanion(RecurringRule rule) =>
      RecurringRuleEntriesCompanion.insert(
        id: rule.id,
        description: rule.description,
        kind: rule.kind.name,
        frequency: rule.frequency.name,
        amountMinor: rule.amount.minorUnits,
        currencyCode: rule.amount.currency.code,
        currencyDecimalDigits: rule.amount.currency.decimalDigits,
        currencySymbol: rule.amount.currency.symbol,
        accountId: rule.accountId,
        category: Value(rule.category),
        firstDueAtMicros: rule.firstDueDate.microsecondsSinceEpoch,
        remindDaysBefore: Value(rule.remindDaysBefore),
        active: Value(rule.active),
      );

  Currency _currency(String code, int digits, String symbol) =>
      Currency(code: code, decimalDigits: digits, symbol: symbol);
}

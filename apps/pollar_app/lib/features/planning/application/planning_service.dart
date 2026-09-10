import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../domain/budget.dart';
import '../domain/planning_repository.dart';
import '../domain/planning_snapshot.dart';
import '../domain/recurring_rule.dart';
import 'planning_ledger_source.dart';

class PlanningService {
  const PlanningService(this._repository, this._ledgerSource);

  final PlanningRepository _repository;
  final PlanningLedgerSource _ledgerSource;

  Future<PlanningSnapshot> load({
    required DateTime month,
    required Currency currency,
    required DateTime today,
  }) async {
    final normalizedMonth = DateTime(month.year, month.month);
    final nextMonth = DateTime(month.year, month.month + 1);
    final budgets = (await _repository.findBudgets())
        .where(
          (item) =>
              item.active &&
              item.month == normalizedMonth &&
              item.limit.currency == currency,
        )
        .toList(growable: false);
    final movements = (await _ledgerSource.listMovements()).where(
      (item) =>
          !item.canceled &&
          item.amount.currency == currency &&
          !item.occurredAt.isBefore(normalizedMonth) &&
          item.occurredAt.isBefore(nextMonth) &&
          (item.kind == PlanningMovementKind.expense ||
              item.kind == PlanningMovementKind.cardPurchase),
    );

    final progress = <BudgetProgress>[];
    for (final budget in budgets) {
      final spentMinor = movements
          .where(
            (item) =>
                item.category?.toLowerCase() == budget.category.toLowerCase(),
          )
          .fold<int>(0, (sum, item) => sum + item.amount.minorUnits);
      final spent = Money(minorUnits: spentMinor, currency: currency);
      final remaining = budget.limit - spent;
      final percent = ((spentMinor * 100) / budget.limit.minorUnits).round();
      progress.add(
        BudgetProgress(
          budget: budget,
          spent: spent,
          remaining: remaining,
          percent: percent,
        ),
      );
    }
    progress.sort((a, b) => b.percent.compareTo(a.percent));

    final rules = (await _repository.findRecurringRules()).where(
      (item) => item.active && item.amount.currency == currency,
    );
    final occurrences = <PlannedOccurrence>[
      for (final rule in rules)
        for (final dueDate in occurrencesInMonth(rule, normalizedMonth))
          PlannedOccurrence(rule: rule, dueDate: dueDate),
    ]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final day = DateTime(today.year, today.month, today.day);
    final reminders = occurrences
        .map(
          (item) => PlanningReminder(
            occurrence: item,
            daysUntilDue: item.dueDate.difference(day).inDays,
          ),
        )
        .where(
          (item) => item.daysUntilDue <= item.occurrence.rule.remindDaysBefore,
        )
        .toList(growable: false);

    Money sum(Iterable<Money> values) =>
        values.fold(Money.zero(currency), (total, value) => total + value);
    return PlanningSnapshot(
      month: normalizedMonth,
      currency: currency,
      budgets: progress,
      occurrences: occurrences,
      reminders: reminders,
      totalBudgeted: sum(budgets.map((item) => item.limit)),
      totalSpent: sum(progress.map((item) => item.spent)),
      recurringExpenses: sum(
        occurrences
            .where((item) => item.rule.kind != RecurringKind.income)
            .map((item) => item.rule.amount),
      ),
      recurringIncome: sum(
        occurrences
            .where((item) => item.rule.kind == RecurringKind.income)
            .map((item) => item.rule.amount),
      ),
    );
  }

  Future<List<PlanningAccountReference>> listAccounts() =>
      _ledgerSource.listAccounts();

  Future<List<Budget>> listBudgets() => _repository.findBudgets();

  Future<List<RecurringRule>> listRecurringRules() =>
      _repository.findRecurringRules();

  Future<void> createBudget(Budget budget) async {
    final duplicate = (await _repository.findBudgets()).any(
      (item) =>
          item.active &&
          item.month == budget.month &&
          item.limit.currency == budget.limit.currency &&
          item.category.toLowerCase() == budget.category.toLowerCase(),
    );
    if (duplicate) {
      throw StateError('An active budget already tracks this category');
    }
    await _repository.addBudget(budget);
  }

  Future<void> createRecurringRule(RecurringRule rule) =>
      _repository.addRecurringRule(rule);

  Future<void> setBudgetActive(Budget budget, bool active) =>
      _repository.replaceBudget(budget.copyWith(active: active));

  Future<void> setRuleActive(RecurringRule rule, bool active) =>
      _repository.replaceRecurringRule(rule.copyWith(active: active));

  static List<DateTime> occurrencesInMonth(RecurringRule rule, DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    if (!rule.firstDueDate.isBefore(end)) return const [];
    switch (rule.frequency) {
      case RecurrenceFrequency.weekly:
        var date = rule.firstDueDate;
        if (date.isBefore(start)) {
          final weeks = (start.difference(date).inDays / 7).floor();
          date = date.add(Duration(days: weeks * 7));
          while (date.isBefore(start)) {
            date = date.add(const Duration(days: 7));
          }
        }
        return [
          for (; date.isBefore(end); date = date.add(const Duration(days: 7)))
            date,
        ];
      case RecurrenceFrequency.monthly:
        final months =
            (month.year - rule.firstDueDate.year) * 12 +
            month.month -
            rule.firstDueDate.month;
        if (months < 0) return const [];
        return [_clampedDate(month.year, month.month, rule.firstDueDate.day)];
      case RecurrenceFrequency.yearly:
        if (month.month != rule.firstDueDate.month ||
            month.year < rule.firstDueDate.year) {
          return const [];
        }
        return [_clampedDate(month.year, month.month, rule.firstDueDate.day)];
    }
  }

  static DateTime _clampedDate(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDay ? lastDay : day);
  }
}

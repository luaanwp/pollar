import 'package:meta/meta.dart';

import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import 'budget.dart';
import 'recurring_rule.dart';

@immutable
class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percent,
  });

  final Budget budget;
  final Money spent;
  final Money remaining;
  final int percent;

  bool get exceeded => spent.compareTo(budget.limit) > 0;
  bool get alerting => percent >= budget.alertThreshold;
}

@immutable
class PlannedOccurrence {
  const PlannedOccurrence({required this.rule, required this.dueDate});

  final RecurringRule rule;
  final DateTime dueDate;
}

@immutable
class PlanningReminder {
  const PlanningReminder({
    required this.occurrence,
    required this.daysUntilDue,
  });

  final PlannedOccurrence occurrence;
  final int daysUntilDue;

  bool get overdue => daysUntilDue < 0;
}

@immutable
class PlanningSnapshot {
  const PlanningSnapshot({
    required this.month,
    required this.currency,
    required this.budgets,
    required this.occurrences,
    required this.reminders,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.recurringExpenses,
    required this.recurringIncome,
  });

  final DateTime month;
  final Currency currency;
  final List<BudgetProgress> budgets;
  final List<PlannedOccurrence> occurrences;
  final List<PlanningReminder> reminders;
  final Money totalBudgeted;
  final Money totalSpent;
  final Money recurringExpenses;
  final Money recurringIncome;

  List<PlannedOccurrence> get subscriptions => occurrences
      .where((item) => item.rule.isSubscription)
      .toList(growable: false);
}

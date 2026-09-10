import 'budget.dart';
import 'recurring_rule.dart';

abstract interface class PlanningRepository {
  Future<List<Budget>> findBudgets();

  Future<List<RecurringRule>> findRecurringRules();

  Future<void> addBudget(Budget budget);

  Future<void> replaceBudget(Budget budget);

  Future<void> addRecurringRule(RecurringRule rule);

  Future<void> replaceRecurringRule(RecurringRule rule);
}

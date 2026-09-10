import '../domain/budget.dart';
import '../domain/planning_repository.dart';
import '../domain/recurring_rule.dart';

class InMemoryPlanningRepository implements PlanningRepository {
  InMemoryPlanningRepository({
    Iterable<Budget> budgets = const [],
    Iterable<RecurringRule> recurringRules = const [],
  }) : _budgets = {for (final item in budgets) item.id: item},
       _rules = {for (final item in recurringRules) item.id: item};

  final Map<String, Budget> _budgets;
  final Map<String, RecurringRule> _rules;

  @override
  Future<List<Budget>> findBudgets() async =>
      List.unmodifiable(_budgets.values);

  @override
  Future<List<RecurringRule>> findRecurringRules() async =>
      List.unmodifiable(_rules.values);

  @override
  Future<void> addBudget(Budget budget) async {
    if (_budgets.containsKey(budget.id)) {
      throw StateError('Budget already exists: ${budget.id}');
    }
    _budgets[budget.id] = budget;
  }

  @override
  Future<void> replaceBudget(Budget budget) async {
    if (!_budgets.containsKey(budget.id)) {
      throw StateError('Budget ${budget.id} does not exist');
    }
    _budgets[budget.id] = budget;
  }

  @override
  Future<void> addRecurringRule(RecurringRule rule) async {
    if (_rules.containsKey(rule.id)) {
      throw StateError('Rule already exists: ${rule.id}');
    }
    _rules[rule.id] = rule;
  }

  @override
  Future<void> replaceRecurringRule(RecurringRule rule) async {
    if (!_rules.containsKey(rule.id)) {
      throw StateError('Rule ${rule.id} does not exist');
    }
    _rules[rule.id] = rule;
  }
}

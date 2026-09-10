import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/currency.dart';
import '../../../shared/application/financial_data_revision.dart';
import '../application/planning_ledger_source.dart';
import '../application/planning_service.dart';
import '../domain/budget.dart';
import '../domain/planning_repository.dart';
import '../domain/planning_snapshot.dart';
import '../domain/recurring_rule.dart';

final planningRepositoryProvider = Provider<PlanningRepository>(
  (ref) => throw StateError('PlanningRepository was not configured'),
);

final planningLedgerSourceProvider = Provider<PlanningLedgerSource>(
  (ref) => throw StateError('PlanningLedgerSource was not configured'),
);

final planningClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final planningServiceProvider = Provider<PlanningService>(
  (ref) => PlanningService(
    ref.watch(planningRepositoryProvider),
    ref.watch(planningLedgerSourceProvider),
  ),
);

class PlanningState {
  const PlanningState({
    required this.snapshot,
    required this.accounts,
    required this.currencies,
    required this.budgets,
    required this.recurringRules,
  });

  final PlanningSnapshot snapshot;
  final List<PlanningAccountReference> accounts;
  final List<Currency> currencies;
  final List<Budget> budgets;
  final List<RecurringRule> recurringRules;
}

final planningProvider =
    AsyncNotifierProvider<PlanningController, PlanningState>(
      PlanningController.new,
    );

class PlanningController extends AsyncNotifier<PlanningState> {
  DateTime? _month;
  Currency? _currency;

  PlanningService get _service => ref.read(planningServiceProvider);

  @override
  Future<PlanningState> build() async {
    ref.watch(financialDataRevisionProvider);
    final today = ref.watch(planningClockProvider)();
    _month ??= DateTime(today.year, today.month);
    return _load(today);
  }

  Future<void> previousMonth() => _changeMonth(-1);

  Future<void> nextMonth() => _changeMonth(1);

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(ref.read(planningClockProvider)()),
    );
  }

  Future<void> selectCurrency(Currency currency) async {
    _currency = currency;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(ref.read(planningClockProvider)()),
    );
  }

  Future<void> createBudget(Budget budget) async {
    await _service.createBudget(budget);
    state = AsyncData(await _load(ref.read(planningClockProvider)()));
  }

  Future<void> createRecurringRule(RecurringRule rule) async {
    await _service.createRecurringRule(rule);
    state = AsyncData(await _load(ref.read(planningClockProvider)()));
  }

  Future<void> setBudgetActive(Budget budget, bool active) async {
    await _service.setBudgetActive(budget, active);
    state = AsyncData(await _load(ref.read(planningClockProvider)()));
  }

  Future<void> setRuleActive(RecurringRule rule, bool active) async {
    await _service.setRuleActive(rule, active);
    state = AsyncData(await _load(ref.read(planningClockProvider)()));
  }

  Future<void> _changeMonth(int delta) async {
    final month = _month!;
    _month = DateTime(month.year, month.month + delta);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(ref.read(planningClockProvider)()),
    );
  }

  Future<PlanningState> _load(DateTime today) async {
    final accounts = (await _service.listAccounts())
        .where((item) => item.active)
        .toList(growable: false);
    final currencies = <Currency>[];
    for (final account in accounts) {
      if (!currencies.contains(account.currency)) {
        currencies.add(account.currency);
      }
    }
    _currency ??= currencies.contains(Currency.brl)
        ? Currency.brl
        : currencies.firstOrNull ?? Currency.brl;
    final budgets = await _service.listBudgets();
    final recurringRules = await _service.listRecurringRules();
    return PlanningState(
      snapshot: await _service.load(
        month: _month!,
        currency: _currency!,
        today: today,
      ),
      accounts: accounts,
      currencies: currencies,
      budgets: budgets,
      recurringRules: recurringRules,
    );
  }
}

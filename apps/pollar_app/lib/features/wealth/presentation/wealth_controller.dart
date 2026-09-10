import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/currency.dart';
import '../../../shared/application/financial_data_revision.dart';
import '../application/wealth_ledger_source.dart';
import '../application/wealth_service.dart';
import '../domain/wealth_asset.dart';
import '../domain/wealth_debt.dart';
import '../domain/wealth_goal.dart';
import '../domain/wealth_repository.dart';
import '../domain/wealth_snapshot.dart';

final wealthRepositoryProvider = Provider<WealthRepository>(
  (ref) => throw StateError('WealthRepository was not configured'),
);

final wealthLedgerSourceProvider = Provider<WealthLedgerSource>(
  (ref) => throw StateError('WealthLedgerSource was not configured'),
);

final wealthClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final wealthServiceProvider = Provider<WealthService>(
  (ref) => WealthService(
    ref.watch(wealthRepositoryProvider),
    ref.watch(wealthLedgerSourceProvider),
  ),
);

class WealthState {
  const WealthState({
    required this.snapshot,
    required this.currencies,
    required this.goals,
    required this.assets,
    required this.debts,
  });

  final WealthSnapshot snapshot;
  final List<Currency> currencies;
  final List<WealthGoal> goals;
  final List<WealthAsset> assets;
  final List<WealthDebt> debts;
}

final wealthProvider = AsyncNotifierProvider<WealthController, WealthState>(
  WealthController.new,
);

class WealthController extends AsyncNotifier<WealthState> {
  Currency? _currency;

  WealthService get _service => ref.read(wealthServiceProvider);

  @override
  Future<WealthState> build() async {
    ref.watch(financialDataRevisionProvider);
    return _load();
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> selectCurrency(Currency currency) async {
    _currency = currency;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> createGoal(WealthGoal goal) async {
    await _service.createGoal(goal);
    state = AsyncData(await _load());
  }

  Future<void> createAsset(WealthAsset asset) async {
    await _service.createAsset(asset);
    state = AsyncData(await _load());
  }

  Future<void> createDebt(WealthDebt debt) async {
    await _service.createDebt(debt);
    state = AsyncData(await _load());
  }

  Future<void> updateGoal(WealthGoal goal) async {
    await _service.updateGoal(goal);
    state = AsyncData(await _load());
  }

  Future<void> updateAsset(WealthAsset asset) async {
    await _service.updateAsset(asset);
    state = AsyncData(await _load());
  }

  Future<void> updateDebt(WealthDebt debt) async {
    await _service.updateDebt(debt);
    state = AsyncData(await _load());
  }

  Future<void> completeGoal(WealthGoal goal) async {
    await _service.completeGoal(goal);
    state = AsyncData(await _load());
  }

  Future<void> settleDebt(WealthDebt debt) async {
    await _service.settleDebt(debt, ref.read(wealthClockProvider)());
    state = AsyncData(await _load());
  }

  Future<void> setGoalActive(WealthGoal goal, bool active) async {
    await _service.setGoalActive(goal, active);
    state = AsyncData(await _load());
  }

  Future<void> setAssetActive(WealthAsset asset, bool active) async {
    await _service.setAssetActive(asset, active);
    state = AsyncData(await _load());
  }

  Future<void> setDebtActive(WealthDebt debt, bool active) async {
    await _service.setDebtActive(debt, active);
    state = AsyncData(await _load());
  }

  Future<WealthState> _load() async {
    final currencies = await _service.listCurrencies();
    _currency ??= currencies.contains(Currency.brl)
        ? Currency.brl
        : currencies.firstOrNull ?? Currency.brl;
    return WealthState(
      snapshot: await _service.load(_currency!),
      currencies: currencies,
      goals: await _service.listGoals(),
      assets: await _service.listAssets(),
      debts: await _service.listDebts(),
    );
  }
}

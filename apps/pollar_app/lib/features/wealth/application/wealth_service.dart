import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../domain/wealth_asset.dart';
import '../domain/wealth_debt.dart';
import '../domain/wealth_goal.dart';
import '../domain/wealth_repository.dart';
import '../domain/wealth_snapshot.dart';
import 'wealth_ledger_source.dart';

class WealthService {
  const WealthService(this._repository, this._ledger);

  final WealthRepository _repository;
  final WealthLedgerSource _ledger;

  Future<List<Currency>> listCurrencies() async {
    final currencies = await _ledger.listCurrencies();
    final configured = <Currency>{
      for (final goal in await _repository.listGoals()) goal.target.currency,
      for (final asset in await _repository.listAssets())
        asset.currentValue.currency,
      for (final debt in await _repository.listDebts())
        debt.outstandingAmount.currency,
    };
    for (final currency in currencies) {
      configured.add(currency);
    }
    if (configured.isEmpty) configured.add(Currency.brl);
    final result = configured.toList()
      ..sort((a, b) => a.code.compareTo(b.code));
    return result;
  }

  Future<WealthSnapshot> load(Currency currency) async {
    final positions = (await _ledger.listConfirmedPositions())
        .where((item) => item.active && item.balance.currency == currency)
        .map((item) {
          final liability = item.balance.isNegative;
          return WealthAccountPosition(
            id: item.id,
            name: item.name,
            amount: liability ? item.balance.abs() : item.balance,
            liability: liability,
          );
        })
        .where((item) => !item.amount.isZero)
        .toList();
    final assets =
        (await _repository.listAssets())
            .where(
              (item) => item.active && item.currentValue.currency == currency,
            )
            .toList()
          ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
    final debts =
        (await _repository.listDebts())
            .where(
              (item) =>
                  item.active &&
                  !item.settled &&
                  item.outstandingAmount.currency == currency,
            )
            .toList()
          ..sort((a, b) => b.outstandingAmount.compareTo(a.outstandingAmount));
    final goals = (await _repository.listGoals())
        .where((item) => item.active && item.target.currency == currency)
        .map(_goalProgress)
        .toList();

    Money sum(Iterable<Money> values) =>
        values.fold(Money.zero(currency), (total, item) => total + item);

    final accountAssets = positions.where((item) => !item.liability);
    final accountDebts = positions.where((item) => item.liability);
    final totalAssets = sum([
      ...accountAssets.map((item) => item.amount),
      ...assets.map((item) => item.currentValue),
    ]);
    final totalLiabilities = sum([
      ...accountDebts.map((item) => item.amount),
      ...debts.map((item) => item.outstandingAmount),
    ]);
    return WealthSnapshot(
      currency: currency,
      accountPositions: List.unmodifiable(positions),
      assets: List.unmodifiable(assets),
      debts: List.unmodifiable(debts),
      goals: List.unmodifiable(goals),
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      netWorth: totalAssets - totalLiabilities,
    );
  }

  Future<List<WealthGoal>> listGoals() => _repository.listGoals();
  Future<List<WealthAsset>> listAssets() => _repository.listAssets();
  Future<List<WealthDebt>> listDebts() => _repository.listDebts();

  Future<void> createGoal(WealthGoal goal) async {
    if ((await _repository.listGoals()).any((item) => item.id == goal.id)) {
      throw StateError('Goal id already exists.');
    }
    if (goal.priority) {
      await _clearPriority(goal.target.currency);
    }
    await _repository.addGoal(goal);
  }

  Future<void> createAsset(WealthAsset asset) async {
    if ((await _repository.listAssets()).any((item) => item.id == asset.id)) {
      throw StateError('Asset id already exists.');
    }
    await _repository.addAsset(asset);
  }

  Future<void> createDebt(WealthDebt debt) async {
    if ((await _repository.listDebts()).any((item) => item.id == debt.id)) {
      throw StateError('Debt id already exists.');
    }
    await _repository.addDebt(debt);
  }

  Future<void> updateGoal(WealthGoal goal) async {
    if (goal.priority) {
      await _clearPriority(goal.target.currency, exceptId: goal.id);
    }
    await _repository.replaceGoal(goal);
  }

  Future<void> updateAsset(WealthAsset asset) =>
      _repository.replaceAsset(asset);

  Future<void> updateDebt(WealthDebt debt) => _repository.replaceDebt(debt);

  Future<void> completeGoal(WealthGoal goal) =>
      updateGoal(goal.copyWith(saved: goal.target));

  Future<void> settleDebt(WealthDebt debt, DateTime now) => updateDebt(
    debt.copyWith(
      outstandingAmount: Money.zero(debt.outstandingAmount.currency),
      updatedAt: now,
    ),
  );

  Future<void> setGoalActive(WealthGoal goal, bool active) =>
      _repository.replaceGoal(goal.copyWith(active: active));
  Future<void> setAssetActive(WealthAsset asset, bool active) =>
      _repository.replaceAsset(asset.copyWith(active: active));
  Future<void> setDebtActive(WealthDebt debt, bool active) =>
      _repository.replaceDebt(debt.copyWith(active: active));

  WealthGoalProgress _goalProgress(WealthGoal goal) {
    final raw = goal.saved.minorUnits * 100 ~/ goal.target.minorUnits;
    final remainingMinor = goal.target.minorUnits - goal.saved.minorUnits;
    return WealthGoalProgress(
      goal: goal,
      percent: raw.clamp(0, 100),
      remaining: Money(
        minorUnits: remainingMinor < 0 ? 0 : remainingMinor,
        currency: goal.target.currency,
      ),
    );
  }

  Future<void> _clearPriority(Currency currency, {String? exceptId}) async {
    for (final goal in await _repository.listGoals()) {
      if (goal.id != exceptId &&
          goal.priority &&
          goal.target.currency == currency) {
        await _repository.replaceGoal(goal.copyWith(priority: false));
      }
    }
  }
}

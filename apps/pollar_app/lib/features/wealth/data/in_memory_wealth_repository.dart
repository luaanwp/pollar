import '../domain/wealth_asset.dart';
import '../domain/wealth_debt.dart';
import '../domain/wealth_goal.dart';
import '../domain/wealth_repository.dart';

class InMemoryWealthRepository implements WealthRepository {
  InMemoryWealthRepository({
    Iterable<WealthGoal> goals = const [],
    Iterable<WealthAsset> assets = const [],
    Iterable<WealthDebt> debts = const [],
  }) : _goals = {for (final item in goals) item.id: item},
       _assets = {for (final item in assets) item.id: item},
       _debts = {for (final item in debts) item.id: item};

  final Map<String, WealthGoal> _goals;
  final Map<String, WealthAsset> _assets;
  final Map<String, WealthDebt> _debts;

  @override
  Future<List<WealthGoal>> listGoals() async => List.of(_goals.values);
  @override
  Future<List<WealthAsset>> listAssets() async => List.of(_assets.values);
  @override
  Future<List<WealthDebt>> listDebts() async => List.of(_debts.values);

  @override
  Future<void> addGoal(WealthGoal goal) => _add(_goals, goal.id, goal);
  @override
  Future<void> addAsset(WealthAsset asset) => _add(_assets, asset.id, asset);
  @override
  Future<void> addDebt(WealthDebt debt) => _add(_debts, debt.id, debt);

  @override
  Future<void> replaceGoal(WealthGoal goal) => _replace(_goals, goal.id, goal);
  @override
  Future<void> replaceAsset(WealthAsset asset) =>
      _replace(_assets, asset.id, asset);
  @override
  Future<void> replaceDebt(WealthDebt debt) => _replace(_debts, debt.id, debt);

  Future<void> _add<T>(Map<String, T> values, String id, T value) async {
    if (values.containsKey(id)) throw StateError('Duplicate id: $id');
    values[id] = value;
  }

  Future<void> _replace<T>(Map<String, T> values, String id, T value) async {
    if (!values.containsKey(id)) throw StateError('Unknown id: $id');
    values[id] = value;
  }
}

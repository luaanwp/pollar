import 'wealth_asset.dart';
import 'wealth_debt.dart';
import 'wealth_goal.dart';

abstract interface class WealthRepository {
  Future<List<WealthGoal>> listGoals();
  Future<List<WealthAsset>> listAssets();
  Future<List<WealthDebt>> listDebts();

  Future<void> addGoal(WealthGoal goal);
  Future<void> addAsset(WealthAsset asset);
  Future<void> addDebt(WealthDebt debt);

  Future<void> replaceGoal(WealthGoal goal);
  Future<void> replaceAsset(WealthAsset asset);
  Future<void> replaceDebt(WealthDebt debt);
}

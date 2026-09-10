import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import 'wealth_asset.dart';
import 'wealth_debt.dart';
import 'wealth_goal.dart';

class WealthAccountPosition {
  const WealthAccountPosition({
    required this.id,
    required this.name,
    required this.amount,
    required this.liability,
  });

  final String id;
  final String name;
  final Money amount;
  final bool liability;
}

class WealthGoalProgress {
  const WealthGoalProgress({
    required this.goal,
    required this.percent,
    required this.remaining,
  });

  final WealthGoal goal;
  final int percent;
  final Money remaining;
}

class WealthSnapshot {
  const WealthSnapshot({
    required this.currency,
    required this.accountPositions,
    required this.assets,
    required this.debts,
    required this.goals,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
  });

  final Currency currency;
  final List<WealthAccountPosition> accountPositions;
  final List<WealthAsset> assets;
  final List<WealthDebt> debts;
  final List<WealthGoalProgress> goals;
  final Money totalAssets;
  final Money totalLiabilities;
  final Money netWorth;

  WealthGoalProgress? get priorityGoal {
    final candidates = goals.where((item) => !item.goal.completed).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final byPriority = a.goal.priority == b.goal.priority
          ? 0
          : (a.goal.priority ? -1 : 1);
      if (byPriority != 0) return byPriority;
      final aDate = a.goal.deadline;
      final bDate = b.goal.deadline;
      if (aDate == null && bDate == null) {
        return a.goal.name.compareTo(b.goal.name);
      }
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });
    return candidates.first;
  }
}

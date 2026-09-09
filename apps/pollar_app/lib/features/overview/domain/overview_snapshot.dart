import '../../../core/ledger/balance_calculator.dart';
import '../../../core/ledger/balance_rules.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

class OverviewCurrencySummary {
  const OverviewCurrencySummary({
    required this.currency,
    required this.confirmed,
    required this.projected,
    required this.projectedMonthlyIncome,
    required this.projectedMonthlyExpenses,
    required this.confirmedCardDebt,
    required this.projectedCardDebt,
  });

  final Currency currency;
  final Money confirmed;
  final Money projected;
  final Money projectedMonthlyIncome;
  final Money projectedMonthlyExpenses;
  final Money confirmedCardDebt;
  final Money projectedCardDebt;

  Money get projectedMonthlyResult =>
      projectedMonthlyIncome - projectedMonthlyExpenses;
}

class OverviewAccountPosition {
  const OverviewAccountPosition({
    required this.id,
    required this.name,
    required this.isCreditCard,
    required this.balance,
  });

  final String id;
  final String name;
  final bool isCreditCard;
  final AccountBalance balance;
}

class OverviewRecentTransaction {
  const OverviewRecentTransaction({
    required this.id,
    required this.description,
    required this.type,
    required this.status,
    required this.displayAmount,
    required this.accountLabel,
    required this.occurredAt,
    this.category,
  });

  final String id;
  final String description;
  final TransactionType type;
  final TransactionStatus status;
  final Money displayAmount;
  final String accountLabel;
  final DateTime occurredAt;
  final String? category;
}

class OverviewSnapshot {
  const OverviewSnapshot({
    required this.summaries,
    required this.accounts,
    required this.recentTransactions,
  });

  final List<OverviewCurrencySummary> summaries;
  final List<OverviewAccountPosition> accounts;
  final List<OverviewRecentTransaction> recentTransactions;

  bool get isEmpty => accounts.isEmpty;

  OverviewCurrencySummary? summaryFor(Currency currency) {
    for (final summary in summaries) {
      if (summary.currency == currency) return summary;
    }
    return null;
  }
}

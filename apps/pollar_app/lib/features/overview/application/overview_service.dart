import '../../../core/ledger/balance_calculator.dart';
import '../../../core/ledger/balance_rules.dart';
import '../../../core/money/money.dart';
import '../domain/overview_snapshot.dart';
import 'overview_data_source.dart';

class OverviewService {
  const OverviewService(this._source);

  final OverviewDataSource _source;

  Future<OverviewSnapshot> load({required DateTime now}) async {
    final data = await _source.load();
    final activeAccounts = data.accounts.where((item) => !item.isArchived);
    final allPostings = data.transactions
        .expand((item) => item.postings)
        .toList();
    final names = {
      for (final account in data.accounts) account.id: account.name,
    };

    final positions =
        [
          for (final account in activeAccounts)
            OverviewAccountPosition(
              id: account.id,
              name: account.name,
              isCreditCard: account.kind == OverviewAccountKind.creditCard,
              balance: computeAccountBalance(
                accountId: account.id,
                openingBalance: account.openingBalance,
                postings: allPostings,
              ),
            ),
        ]..sort((a, b) {
          final byKind = a.isCreditCard == b.isCreditCard
              ? 0
              : (a.isCreditCard ? 1 : -1);
          return byKind != 0 ? byKind : a.name.compareTo(b.name);
        });

    final currencies = activeAccounts
        .map((account) => account.currency)
        .toSet();
    final summaries = <OverviewCurrencySummary>[];
    for (final currency in currencies) {
      Money sum(Iterable<Money> values) =>
          values.fold(Money.zero(currency), (total, value) => total + value);

      final cash = positions.where(
        (position) =>
            !position.isCreditCard &&
            position.balance.confirmed.currency == currency,
      );
      final cards = positions.where(
        (position) =>
            position.isCreditCard &&
            position.balance.confirmed.currency == currency,
      );
      final monthTransactions = data.transactions.where(
        (transaction) =>
            transaction.amount.currency == currency &&
            transaction.occurredAt.year == now.year &&
            transaction.occurredAt.month == now.month &&
            transaction.status.affectsProjected &&
            transaction.type.countsAsIncomeOrExpense,
      );

      summaries.add(
        OverviewCurrencySummary(
          currency: currency,
          confirmed: sum(cash.map((item) => item.balance.confirmed)),
          projected: sum(cash.map((item) => item.balance.projected)),
          projectedMonthlyIncome: sum(
            monthTransactions
                .where((item) => item.type == TransactionType.income)
                .map((item) => item.amount),
          ),
          projectedMonthlyExpenses: sum(
            monthTransactions
                .where((item) => item.type != TransactionType.income)
                .map((item) => item.amount),
          ),
          confirmedCardDebt: sum(
            cards.map((item) => _debtMagnitude(item.balance.confirmed)),
          ),
          projectedCardDebt: sum(
            cards.map((item) => _debtMagnitude(item.balance.projected)),
          ),
        ),
      );
    }
    summaries.sort((a, b) => a.currency.code.compareTo(b.currency.code));

    final recentSource = [...data.transactions]
      ..sort((a, b) {
        final byDate = b.occurredAt.compareTo(a.occurredAt);
        return byDate != 0 ? byDate : b.id.compareTo(a.id);
      });
    final recent = recentSource.take(5).map((transaction) {
      final account = names[transaction.accountId] ?? 'Conta indisponível';
      final counter = transaction.counterAccountId == null
          ? null
          : names[transaction.counterAccountId!];
      return OverviewRecentTransaction(
        id: transaction.id,
        description: transaction.description,
        type: transaction.type,
        status: transaction.status,
        displayAmount: transaction.postings.first.signedAmount,
        accountLabel: counter == null ? account : '$account → $counter',
        occurredAt: transaction.occurredAt,
        category: transaction.category,
      );
    }).toList();

    return OverviewSnapshot(
      summaries: List.unmodifiable(summaries),
      accounts: List.unmodifiable(positions),
      recentTransactions: List.unmodifiable(recent),
    );
  }

  Money _debtMagnitude(Money balance) =>
      balance.isNegative ? balance.abs() : Money.zero(balance.currency);
}

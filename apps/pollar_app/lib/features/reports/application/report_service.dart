import '../../../core/ledger/balance_rules.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../domain/report_snapshot.dart';
import 'report_data_source.dart';

class ReportService {
  const ReportService(this._source);

  final ReportDataSource _source;

  Future<ReportSnapshot> load({
    required DateTime now,
    int monthCount = 6,
  }) async {
    if (monthCount < 1 || monthCount > 24) {
      throw RangeError.range(monthCount, 1, 24, 'monthCount');
    }
    final data = await _source.load();
    final endMonth = DateTime(now.year, now.month);
    final startMonth = DateTime(now.year, now.month - monthCount + 1);
    final endExclusive = DateTime(now.year, now.month + 1);
    final activeAccounts = data.accounts.where((item) => !item.isArchived);
    final currencies = <Currency>{
      ...activeAccounts.map((item) => item.currency),
      ...data.transactions
          .where(_countsInReports)
          .map((item) => item.amount.currency),
    }.toList()..sort((a, b) => a.code.compareTo(b.code));

    final reports = <ReportCurrencySnapshot>[];
    for (final currency in currencies) {
      final accounts = activeAccounts
          .where((item) => item.currency == currency)
          .toList(growable: false);
      final accountIds = accounts.map((item) => item.id).toSet();
      final currencyTransactions = data.transactions
          .where((item) => item.amount.currency == currency)
          .toList(growable: false);
      final counted =
          currencyTransactions
              .where(_countsInReports)
              .where(
                (item) =>
                    !item.occurredAt.isBefore(startMonth) &&
                    item.occurredAt.isBefore(endExclusive),
              )
              .toList()
            ..sort((a, b) {
              final byDate = a.occurredAt.compareTo(b.occurredAt);
              return byDate != 0 ? byDate : a.id.compareTo(b.id);
            });

      Money sum(Iterable<Money> values) =>
          values.fold(Money.zero(currency), (total, value) => total + value);

      final months = <ReportMonth>[];
      for (var offset = 0; offset < monthCount; offset++) {
        final month = DateTime(startMonth.year, startMonth.month + offset);
        final nextMonth = DateTime(month.year, month.month + 1);
        final monthTransactions = counted.where(
          (item) =>
              item.occurredAt.year == month.year &&
              item.occurredAt.month == month.month,
        );
        final income = sum(
          monthTransactions
              .where((item) => item.type == TransactionType.income)
              .map((item) => item.amount),
        );
        final expenses = sum(
          monthTransactions
              .where((item) => item.type != TransactionType.income)
              .map((item) => item.amount),
        );
        final opening = sum(accounts.map((item) => item.openingBalance));
        final postings = currencyTransactions
            .where(
              (item) =>
                  item.status.affectsConfirmed &&
                  item.occurredAt.isBefore(nextMonth),
            )
            .expand((item) => item.postings)
            .where((posting) => accountIds.contains(posting.accountId))
            .map((posting) => posting.signedAmount);
        final accountNetBalance = opening + sum(postings);
        months.add(
          ReportMonth(
            month: month,
            income: income,
            expenses: expenses,
            netResult: income - expenses,
            accountNetBalance: accountNetBalance,
          ),
        );
      }

      final categoryTotals = <String, Money>{};
      for (final transaction in counted.where(
        (item) => item.type != TransactionType.income,
      )) {
        final category = transaction.category?.trim();
        final name = category == null || category.isEmpty
            ? 'Sem categoria'
            : category;
        categoryTotals[name] =
            (categoryTotals[name] ?? Money.zero(currency)) + transaction.amount;
      }
      final categories =
          [
            for (final entry in categoryTotals.entries)
              ReportCategory(name: entry.key, amount: entry.value),
          ]..sort((a, b) {
            final byAmount = b.amount.minorUnits.compareTo(a.amount.minorUnits);
            return byAmount != 0 ? byAmount : a.name.compareTo(b.name);
          });

      final totalIncome = sum(
        counted
            .where((item) => item.type == TransactionType.income)
            .map((item) => item.amount),
      );
      final totalExpenses = sum(
        counted
            .where((item) => item.type != TransactionType.income)
            .map((item) => item.amount),
      );
      reports.add(
        ReportCurrencySnapshot(
          currency: currency,
          periodStart: startMonth,
          periodEnd: endMonth,
          months: List.unmodifiable(months),
          categories: List.unmodifiable(categories),
          exportRows: List.unmodifiable([
            for (final item in counted)
              ReportExportRow(
                id: item.id,
                occurredAt: item.occurredAt,
                description: item.description,
                category: item.category?.trim().isNotEmpty == true
                    ? item.category!.trim()
                    : 'Sem categoria',
                type: item.type,
                status: item.status,
                signedAmount: item.type == TransactionType.income
                    ? item.amount
                    : -item.amount,
              ),
          ]),
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          netResult: totalIncome - totalExpenses,
        ),
      );
    }

    return ReportSnapshot(reports: List.unmodifiable(reports));
  }

  static bool _countsInReports(ReportTransactionRecord item) =>
      item.status.affectsConfirmed && item.type.countsAsIncomeOrExpense;
}

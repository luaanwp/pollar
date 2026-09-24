import '../../../core/ledger/balance_rules.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

class ReportMonth {
  const ReportMonth({
    required this.month,
    required this.income,
    required this.expenses,
    required this.netResult,
    required this.accountNetBalance,
  });

  final DateTime month;
  final Money income;
  final Money expenses;
  final Money netResult;
  final Money accountNetBalance;
}

class ReportCategory {
  const ReportCategory({required this.name, required this.amount});

  final String name;
  final Money amount;
}

class ReportExportRow {
  const ReportExportRow({
    required this.id,
    required this.occurredAt,
    required this.description,
    required this.category,
    required this.type,
    required this.status,
    required this.signedAmount,
  });

  final String id;
  final DateTime occurredAt;
  final String description;
  final String category;
  final TransactionType type;
  final TransactionStatus status;
  final Money signedAmount;
}

class ReportCurrencySnapshot {
  const ReportCurrencySnapshot({
    required this.currency,
    required this.periodStart,
    required this.periodEnd,
    required this.months,
    required this.categories,
    required this.exportRows,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netResult,
  });

  final Currency currency;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<ReportMonth> months;
  final List<ReportCategory> categories;
  final List<ReportExportRow> exportRows;
  final Money totalIncome;
  final Money totalExpenses;
  final Money netResult;
}

class ReportSnapshot {
  const ReportSnapshot({required this.reports});

  final List<ReportCurrencySnapshot> reports;

  bool get isEmpty => reports.isEmpty;

  ReportCurrencySnapshot? reportFor(Currency currency) {
    for (final report in reports) {
      if (report.currency == currency) return report;
    }
    return null;
  }
}

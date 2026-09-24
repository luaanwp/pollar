import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/reports/application/report_service.dart';

import '../../../support/report_fixture.dart';

void main() {
  final service = ReportService(const ReportFixtureDataSource());

  test(
    'builds six exact monthly comparisons from confirmed ledger data',
    () async {
      final snapshot = await service.load(now: reportFixtureNow);
      final report = snapshot.reportFor(Currency.brl)!;

      expect(report.months, hasLength(6));
      expect(report.months.first.month, DateTime(2026, 4));
      expect(report.months.first.income, _brl(400000));
      expect(report.months.first.expenses, _brl(150000));
      expect(report.months.first.netResult, _brl(250000));
      expect(report.months.first.accountNetBalance, _brl(850000));
      expect(report.months.last.income, _brl(550000));
      expect(report.months.last.expenses, _brl(250000));
    },
  );

  test('excludes planned, canceled and internal movements', () async {
    final report = (await service.load(now: reportFixtureNow))
        .reportFor(Currency.brl)!;

    expect(report.totalIncome, _brl(2900000));
    expect(report.totalExpenses, _brl(1160000));
    expect(report.netResult, _brl(1740000));
    expect(
      report.exportRows.map((item) => item.id),
      isNot(contains('planned')),
    );
    expect(
      report.exportRows.map((item) => item.id),
      isNot(contains('transfer')),
    );
    expect(
      report.exportRows.map((item) => item.id),
      isNot(contains('canceled')),
    );
  });

  test('sorts expense categories and never mixes currencies', () async {
    final snapshot = await service.load(now: reportFixtureNow);
    final brl = snapshot.reportFor(Currency.brl)!;
    final usd = snapshot.reportFor(Currency.usd)!;

    expect(brl.categories.first.name, 'Moradia');
    expect(brl.categories.first.amount, _brl(550000));
    expect(usd.totalIncome, _usd(25000));
    expect(usd.totalExpenses, _usd(0));
    expect(usd.months.last.accountNetBalance, _usd(35000));
  });

  test('rejects an unsupported comparison window', () {
    expect(
      () => service.load(now: reportFixtureNow, monthCount: 0),
      throwsRangeError,
    );
  });
}

Money _brl(int minor) => Money(minorUnits: minor, currency: Currency.brl);
Money _usd(int minor) => Money(minorUnits: minor, currency: Currency.usd);

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/features/reports/application/report_export_service.dart';
import 'package:pollar_app/features/reports/application/report_service.dart';

import '../../../support/report_fixture.dart';

void main() {
  test('creates deterministic CSV with a matching SHA-256 digest', () async {
    final report = (await ReportService(
      const ReportFixtureDataSource(),
    ).load(now: reportFixtureNow)).reportFor(Currency.brl)!;
    const service = ReportExportService();

    final first = service.build(report);
    final second = service.build(report);

    expect(first.fileName, 'pollar-relatorio-2026-04-a-2026-09-BRL.csv');
    expect(first.csv, second.csv);
    expect(first.sha256, second.sha256);
    expect(first.sha256, sha256.convert(utf8.encode(first.csv)).toString());
    expect(first.csv, contains('# basis=confirmed_and_reconciled'));
    expect(first.csv, contains('"apr-income";2026-04-01;"Salário abril"'));
    expect(first.csv, contains(';BRL;-150000'));
    expect(first.csv, isNot(contains('Receita prevista')));
  });
}

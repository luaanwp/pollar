import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/features/reports/application/report_exporter.dart';
import 'package:pollar_app/features/reports/presentation/reports_controller.dart';
import 'package:pollar_app/features/reports/presentation/reports_screen.dart';
import 'package:pollar_app/shared/presentation/money_text.dart';

import '../../../support/analysis_redesign_fixture.dart';

void main() {
  void viewport(WidgetTester tester, Size size, [double scale = 1]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  ProviderContainer scope(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(ReportsScreen)));

  testWidgets(
    'compact result precedes export and leaves monthly flow visible',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await tester.pumpWidget(analysisRedesignApp(wealth: false));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Resultado do período')).dy,
        lessThan(tester.getTopLeft(find.text('Exportar CSV')).dy),
      );
      expect(find.text('Fluxo mês a mês').hitTestable(), findsOneWidget);
      expect(
        find.textContaining('Transferências e pagamentos de fatura'),
        findsNothing,
      );
      await tester.tap(find.text('Base confirmada'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Transferências e pagamentos de fatura'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'all six balance points have exact visible textual counterparts',
    (tester) async {
      viewport(tester, const Size(1200, 1000));
      await tester.pumpWidget(analysisRedesignApp(wealth: false));
      await tester.pumpAndSettle();
      final report = scope(tester)
          .read(reportsProvider)
          .requireValue
          .reportFor(Currency.brl)!;
      final band = find
          .ancestor(
            of: find.text('Saldo líquido das contas'),
            matching: find.byType(Semantics),
          )
          .first;
      final amounts = tester
          .widgetList<MoneyText>(
            find.descendant(of: band, matching: find.byType(MoneyText)),
          )
          .map((w) => w.money.minorUnits);
      expect(
        amounts,
        orderedEquals(report.months.map((m) => m.accountNetBalance.minorUnits)),
      );
    },
  );

  testWidgets('currency selector scopes every figure and exported CSV', (
    tester,
  ) async {
    viewport(tester, const Size(1200, 1000));
    final exporter = RecordingAnalysisExporter();
    await tester.pumpWidget(
      analysisRedesignApp(wealth: false, exporter: exporter),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<Currency>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD').last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<MoneyText>(find.byType(MoneyText))
          .every((w) => w.money.currency == Currency.usd),
      isTrue,
    );
    expect(find.text('Moradia'), findsNothing);
    await tester.tap(find.text('Exportar CSV'));
    await tester.pumpAndSettle();
    expect(exporter.document!.fileName, contains('USD.csv'));
    expect(exporter.document!.csv, isNot(contains('Salário abril')));
  });

  testWidgets(
    'export pending prevents duplicate activation and keeps current report',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final exporter = _PendingExport();
      await tester.pumpWidget(
        analysisRedesignApp(wealth: false, exporter: exporter),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exportar CSV'));
      await tester.pump();
      await tester.tap(find.text('Exportar CSV'));
      await tester.pump();
      expect(exporter.calls, 1);
      expect(find.text('Resultado do período'), findsOneWidget);
      exporter.release.complete(
        const ReportExportResult(
          csvPath: 'report.csv',
          checksumPath: 'report.csv.sha256',
        ),
      );
      await tester.pumpAndSettle();
    },
  );

  testWidgets('privacy discards chart frames and all amounts immediately', (
    tester,
  ) async {
    viewport(tester, const Size(1200, 1000));
    await tester.pumpWidget(analysisRedesignApp(wealth: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    final before = tester.getRect(find.text('Fluxo mês a mês'));
    scope(tester).read(privacyModeProvider.notifier).set(true);
    await tester.pump();
    expect(find.byType(MoneyText), findsNothing);
    expect(find.text('Valores ocultos'), findsNWidgets(2));
    expect(tester.getRect(find.text('Fluxo mês a mês')), before);
    await tester.scrollUntilVisible(
      find.text('Composição das saídas'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('••%'), findsWidgets);
  });

  for (final spec in [(320.0, 2.0), (640.0, 1.3), (1024.0, 1.0)]) {
    testWidgets(
      'long report values and categories fit ${spec.$1}/${spec.$2}x',
      (tester) async {
        viewport(tester, Size(spec.$1, 1000), spec.$2);
        await tester.pumpWidget(analysisRedesignApp(wealth: false, long: true));
        await tester.pumpAndSettle();
        for (final heading in [
          'Fluxo mês a mês',
          'Saldo líquido das contas',
          'Composição das saídas',
        ]) {
          await tester.scrollUntilVisible(
            find.text(heading),
            350,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: heading);
        }
        expect(find.text(longAnalysisCategory), findsOneWidget);
      },
    );
  }

  testWidgets('empty report offers no fabricated chart or export', (
    tester,
  ) async {
    viewport(tester, const Size(320, 844), 2);
    await tester.pumpWidget(analysisRedesignApp(wealth: false, empty: true));
    await tester.pumpAndSettle();
    expect(find.text('Ainda não há dados para relatar'), findsOneWidget);
    expect(find.byType(MoneyText), findsNothing);
    expect(find.text('Exportar CSV'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _PendingExport implements ReportExporter {
  final release = Completer<ReportExportResult>();
  int calls = 0;
  @override
  Future<ReportExportResult> export(ReportExportDocument document) {
    calls++;
    return release.future;
  }
}

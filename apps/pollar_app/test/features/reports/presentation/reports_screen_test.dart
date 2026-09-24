import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';
import 'package:pollar_app/features/reports/application/report_exporter.dart';
import 'package:pollar_app/features/reports/presentation/reports_controller.dart';
import 'package:pollar_app/features/reports/presentation/reports_screen.dart';

import '../../../support/report_fixture.dart';

void main() {
  testWidgets('shows reconciled report evidence', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Relatórios'), findsOneWidget);
    expect(find.text('Resultado do período'), findsOneWidget);
    expect(find.text('Fluxo mês a mês'), findsOneWidget);
    expect(find.text('Saldo líquido das contas'), findsOneWidget);
    expect(_moneySemantics('entrada, BRL +R\$ 17.400,00'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Composição das saídas'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Composição das saídas'), findsOneWidget);
    expect(find.text('Moradia'), findsOneWidget);
  });

  testWidgets('exports the visible currency report', (tester) async {
    final exporter = _RecordingExporter();
    await tester.pumpWidget(_app(exporter: exporter));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exportar CSV'));
    await tester.pumpAndSettle();

    expect(exporter.document, isNotNull);
    expect(exporter.document!.fileName, contains('BRL.csv'));
    expect(find.textContaining('Relatório CSV'), findsOneWidget);
  });

  testWidgets('supports 200 percent text without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Composição das saídas'),
      700,
      scrollable: find.byType(Scrollable).first,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Composição das saídas'), findsOneWidget);
  });

  testWidgets('privacy mode neutralizes values and proportional graphics', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ReportsScreen)),
    );
    container.read(privacyModeProvider.notifier).set(true);
    await tester.pumpAndSettle();

    expect(find.text('Valores ocultos'), findsNWidgets(2));
    await tester.scrollUntilVisible(
      find.text('Composição das saídas'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('••%'), findsWidgets);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}

Finder _moneySemantics(String label) => find.byWidgetPredicate(
  (widget) => widget is Text && widget.semanticsLabel == label,
);

Widget _app({_RecordingExporter? exporter}) => ProviderScope(
  overrides: [
    reportDataSourceProvider.overrideWithValue(const ReportFixtureDataSource()),
    reportExporterProvider.overrideWithValue(exporter ?? _RecordingExporter()),
    reportClockProvider.overrideWithValue(() => reportFixtureNow),
  ],
  child: MaterialApp(
    theme: PollarTheme.light(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const Scaffold(body: ReportsScreen()),
  ),
);

class _RecordingExporter implements ReportExporter {
  ReportExportDocument? document;

  @override
  Future<ReportExportResult> export(ReportExportDocument document) async {
    this.document = document;
    return const ReportExportResult(
      csvPath: 'C:\\Downloads\\report.csv',
      checksumPath: 'C:\\Downloads\\report.csv.sha256',
    );
  }
}

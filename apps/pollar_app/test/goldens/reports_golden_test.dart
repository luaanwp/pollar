import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/reports/application/report_exporter.dart';
import 'package:pollar_app/features/reports/presentation/reports_controller.dart';
import 'package:pollar_app/features/reports/presentation/reports_screen.dart';

import '../support/report_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'));
    final lucide = FontLoader('packages/lucide_icons_flutter/Lucide')
      ..addFont(
        rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
      );
    await Future.wait([inter.load(), lucide.load()]);
  });

  Future<void> render(WidgetTester tester, Size size, String golden) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_fixtureApp());
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
  }

  testWidgets(
    'reports compact 390x844',
    (tester) => render(tester, const Size(390, 844), 'reports_390x844.png'),
  );

  testWidgets(
    'reports wide 1200x900',
    (tester) => render(tester, const Size(1200, 900), 'reports_1200x900.png'),
  );

  testWidgets('reports compact at 200 percent text', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(_fixtureApp());
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('reports_text_200_390x844.png'),
    );
  });

  testWidgets('reports compact privacy', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_fixtureApp());
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ReportsScreen)),
    );
    container.read(privacyModeProvider.notifier).set(true);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('reports_privacy_390x844.png'),
    );
  });
}

Widget _fixtureApp() => ProviderScope(
  overrides: [
    reportDataSourceProvider.overrideWithValue(const ReportFixtureDataSource()),
    reportExporterProvider.overrideWithValue(const _NoopExporter()),
    reportClockProvider.overrideWithValue(() => reportFixtureNow),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
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

class _NoopExporter implements ReportExporter {
  const _NoopExporter();

  @override
  Future<ReportExportResult> export(ReportExportDocument document) async =>
      const ReportExportResult(csvPath: '', checksumPath: '');
}

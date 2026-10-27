import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/statements/presentation/card_statement_screen.dart';
import 'package:pollar_app/features/statements/presentation/statement_controller.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';

import '../support/statement_fixture.dart';

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

  Future<void> render(
    WidgetTester tester,
    Size size,
    String golden, {
    int pendingPaymentMinor = 0,
    bool dark = false,
    bool privacy = false,
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statementDataSourceProvider.overrideWithValue(
            StatementFixtureDataSource(
              pendingPaymentMinor: pendingPaymentMinor,
            ),
          ),
          statementClockProvider.overrideWithValue(() => statementFixtureNow),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? PollarTheme.dark() : PollarTheme.light(),
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(body: CardStatementScreen(cardId: 'card')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (privacy) {
      ProviderScope.containerOf(
        tester.element(find.byType(CardStatementScreen)),
      ).read(privacyModeProvider.notifier).set(true);
      await tester.pumpAndSettle();
    }
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
  }

  testWidgets(
    'statement compact 390x844',
    (tester) => render(tester, const Size(390, 844), 'statement_390x844.png'),
  );

  for (final sample in [
    (
      size: const Size(390, 844),
      dark: true,
      scale: 1.0,
      privacy: false,
      name: 'statement_390_dark.png',
    ),
    (
      size: const Size(1200, 900),
      dark: true,
      scale: 1.0,
      privacy: false,
      name: 'statement_1200_dark.png',
    ),
    (
      size: const Size(320, 844),
      dark: false,
      scale: 1.3,
      privacy: false,
      name: 'statement_320_130pct.png',
    ),
    (
      size: const Size(390, 900),
      dark: false,
      scale: 2.0,
      privacy: false,
      name: 'statement_390_2x.png',
    ),
    (
      size: const Size(1200, 1000),
      dark: false,
      scale: 2.0,
      privacy: false,
      name: 'statement_1200_2x.png',
    ),
    (
      size: const Size(390, 844),
      dark: false,
      scale: 1.0,
      privacy: true,
      name: 'statement_privacy_390.png',
    ),
    (
      size: const Size(1200, 900),
      dark: true,
      scale: 1.0,
      privacy: true,
      name: 'statement_privacy_1200_dark.png',
    ),
  ]) {
    testWidgets(
      sample.name,
      (tester) => render(
        tester,
        sample.size,
        sample.name,
        dark: sample.dark,
        scale: sample.scale,
        privacy: sample.privacy,
      ),
    );
  }

  testWidgets(
    'statement wide 1200x900',
    (tester) => render(tester, const Size(1200, 900), 'statement_1200x900.png'),
  );

  testWidgets(
    'statement with pending payment compact 390x844',
    (tester) => render(
      tester,
      const Size(390, 844),
      'statement_pending_390x844.png',
      pendingPaymentMinor: 20000,
    ),
  );

  testWidgets(
    'statement with pending payment wide 1200x900',
    (tester) => render(
      tester,
      const Size(1200, 900),
      'statement_pending_1200x900.png',
      pendingPaymentMinor: 20000,
    ),
  );
}

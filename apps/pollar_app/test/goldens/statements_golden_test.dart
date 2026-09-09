import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/statements/presentation/card_statement_screen.dart';
import 'package:pollar_app/features/statements/presentation/statement_controller.dart';

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

  Future<void> render(WidgetTester tester, Size size, String golden) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statementDataSourceProvider.overrideWithValue(
            StatementFixtureDataSource(),
          ),
          statementClockProvider.overrideWithValue(() => statementFixtureNow),
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
          home: const Scaffold(body: CardStatementScreen(cardId: 'card')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
  }

  testWidgets(
    'statement compact 390x844',
    (tester) => render(tester, const Size(390, 844), 'statement_390x844.png'),
  );

  testWidgets(
    'statement wide 1200x900',
    (tester) => render(tester, const Size(1200, 900), 'statement_1200x900.png'),
  );
}

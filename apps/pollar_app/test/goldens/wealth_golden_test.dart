import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/wealth/data/in_memory_wealth_repository.dart';
import 'package:pollar_app/features/wealth/domain/wealth_goal.dart';
import 'package:pollar_app/features/wealth/presentation/wealth_controller.dart';
import 'package:pollar_app/features/wealth/presentation/wealth_screen.dart';

import '../support/wealth_fixture.dart';

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
    'wealth compact 390x844',
    (tester) => render(tester, const Size(390, 844), 'wealth_390x844.png'),
  );

  testWidgets(
    'wealth wide 1200x900',
    (tester) => render(tester, const Size(1200, 900), 'wealth_1200x900.png'),
  );

  testWidgets('wealth goal form wide dark', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_fixtureApp(dark: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova meta'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('wealth_goal_dark_1200x900.png'),
    );
  });

  testWidgets('wealth compact at 200 percent text', (tester) async {
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
      matchesGoldenFile('wealth_text_200_390x844.png'),
    );
  });

  testWidgets('wealth goal saving compact', (tester) async {
    final repository = _PendingWealthRepository();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_fixtureApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova meta'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Casa própria');
    await tester.enterText(fields.at(1), '100.000,00');
    await tester.tap(find.text('Salvar meta'));
    await tester.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('wealth_goal_saving_390x844.png'),
    );
    repository.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('wealth management wide', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_fixtureApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Gerenciar registros'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('wealth_management_1200x900.png'),
    );
  });

  testWidgets('wealth pause confirmation compact', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_fixtureApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Gerenciar registros'),
      900,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Pausar').first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pausar').first);
    await tester.pumpAndSettle();
    expect(find.text('Pausar meta?'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('wealth_pause_confirmation_390x844.png'),
    );
  });
}

Widget _fixtureApp({bool dark = false, InMemoryWealthRepository? repository}) =>
    ProviderScope(
      overrides: [
        wealthRepositoryProvider.overrideWithValue(
          repository ?? createWealthFixtureRepository(),
        ),
        wealthLedgerSourceProvider.overrideWithValue(
          const WealthFixtureLedgerSource(),
        ),
        wealthClockProvider.overrideWithValue(() => wealthFixtureNow),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: PollarTheme.light(),
        darkTheme: PollarTheme.dark(),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(body: WealthScreen()),
      ),
    );

class _PendingWealthRepository extends InMemoryWealthRepository {
  final _write = Completer<void>();

  @override
  Future<void> addGoal(WealthGoal goal) => _write.future;

  void complete() => _write.complete();
}

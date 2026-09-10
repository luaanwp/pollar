import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/planning/presentation/planning_controller.dart';
import 'package:pollar_app/features/planning/presentation/planning_screen.dart';
import 'package:pollar_app/features/planning/data/in_memory_planning_repository.dart';
import 'package:pollar_app/features/planning/domain/budget.dart';

import '../support/planning_fixture.dart';

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
          planningRepositoryProvider.overrideWithValue(
            createPlanningFixtureRepository(),
          ),
          planningLedgerSourceProvider.overrideWithValue(
            const PlanningFixtureLedgerSource(),
          ),
          planningClockProvider.overrideWithValue(() => planningFixtureNow),
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
          home: const Scaffold(body: PlanningScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
  }

  testWidgets(
    'planning compact 390x844',
    (tester) => render(tester, const Size(390, 844), 'planning_390x844.png'),
  );

  testWidgets(
    'planning wide 1200x900',
    (tester) => render(tester, const Size(1200, 900), 'planning_1200x900.png'),
  );

  testWidgets('planning budget validation compact', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_fixtureApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo orçamento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar orçamento'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('planning_budget_validation_390x844.png'),
    );
  });

  testWidgets('planning recurring form wide dark', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_fixtureApp(dark: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo compromisso'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('planning_recurring_dark_1200x900.png'),
    );
  });

  testWidgets('planning compact at 200 percent text', (tester) async {
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
      matchesGoldenFile('planning_text_200_390x844.png'),
    );
  });

  testWidgets('planning budget saving compact', (tester) async {
    final repository = _PendingPlanningRepository();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_fixtureApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo orçamento'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Saúde');
    await tester.enterText(fields.at(1), '250,00');
    await tester.tap(find.text('Salvar orçamento'));
    await tester.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('planning_budget_saving_390x844.png'),
    );
    repository.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('planning management wide', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_fixtureApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Gerenciar planejamento'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('planning_management_1200x900.png'),
    );
  });

  testWidgets('planning pause confirmation compact', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_fixtureApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Gerenciar planejamento'),
      800,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Pausar').first);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('planning_pause_confirmation_390x844.png'),
    );
  });
}

Widget _fixtureApp({
  bool dark = false,
  InMemoryPlanningRepository? repository,
}) => ProviderScope(
  overrides: [
    planningRepositoryProvider.overrideWithValue(
      repository ?? createPlanningFixtureRepository(),
    ),
    planningLedgerSourceProvider.overrideWithValue(
      const PlanningFixtureLedgerSource(),
    ),
    planningClockProvider.overrideWithValue(() => planningFixtureNow),
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
    home: const Scaffold(body: PlanningScreen()),
  ),
);

class _PendingPlanningRepository extends InMemoryPlanningRepository {
  final _write = Completer<void>();

  @override
  Future<void> addBudget(Budget budget) => _write.future;

  void complete() => _write.complete();
}

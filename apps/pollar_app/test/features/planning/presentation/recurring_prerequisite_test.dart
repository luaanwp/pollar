import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/planning/data/in_memory_planning_repository.dart';
import 'package:pollar_app/features/planning/presentation/planning_controller.dart';
import 'package:pollar_app/features/planning/presentation/planning_screen.dart';

import '../../../support/planning_fixture.dart';
import '../../../support/planning_redesign_fixture.dart';

void main() {
  for (final width in [390.0, 1200.0]) {
    testWidgets(
      'empty account catalogue explains commitment and leads to accounts at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = InMemoryPlanningRepository();
        final router = GoRouter(
          initialLocation: '/planning',
          routes: [
            GoRoute(
              path: '/planning',
              builder: (_, _) => const Scaffold(body: PlanningScreen()),
            ),
            GoRoute(
              path: '/accounts',
              builder: (_, _) =>
                  const Scaffold(body: Text('Catálogo de contas')),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              planningRepositoryProvider.overrideWithValue(repository),
              planningLedgerSourceProvider.overrideWithValue(
                const EmptyPlanningLedgerSource(),
              ),
              planningClockProvider.overrideWithValue(() => planningFixtureNow),
            ],
            child: MaterialApp.router(
              theme: PollarTheme.light(),
              routerConfig: router,
              locale: const Locale('pt', 'BR'),
              supportedLocales: const [Locale('pt', 'BR')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Novo compromisso'));
        await tester.pumpAndSettle();
        expect(find.text('Uma conta primeiro'), findsOneWidget);
        await tester.tap(find.text('Voltar ao planejamento'));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, '/planning');
        expect(find.text('Uma conta primeiro'), findsNothing);
        await tester.tap(find.text('Novo compromisso'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver contas'));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, '/accounts');
        expect(find.text('Catálogo de contas'), findsOneWidget);
        expect(await repository.findRecurringRules(), isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('an active account still opens the recurring form directly', (
    tester,
  ) async {
    await tester.pumpWidget(planningRedesignApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo compromisso'));
    await tester.pumpAndSettle();
    expect(find.text('Salvar compromisso'), findsOneWidget);
    expect(find.text('Uma conta primeiro'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

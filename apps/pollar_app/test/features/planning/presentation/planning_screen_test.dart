import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/planning/presentation/planning_controller.dart';
import 'package:pollar_app/features/planning/presentation/planning_screen.dart';
import 'package:pollar_app/features/planning/data/in_memory_planning_repository.dart';
import 'package:pollar_app/features/planning/domain/budget.dart';

import '../../../support/planning_fixture.dart';

void main() {
  testWidgets('shows reconciled planning bands', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Planejamento de Setembro 2026'), findsOneWidget);
    expect(find.text('R\$ 1.000,00'), findsWidgets);
    expect(find.text('74%'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
    expect(find.text('Aluguel'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Assinaturas'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Streaming'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Lembretes locais'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Lembretes locais'), findsOneWidget);
  });

  testWidgets('validates a new budget before saving', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo orçamento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar orçamento'));
    await tester.pumpAndSettle();

    expect(find.text('Informe a categoria acompanhada.'), findsOneWidget);
    expect(find.text('Informe o valor.'), findsOneWidget);
  });

  testWidgets('keeps budget fields when persistence fails', (tester) async {
    await tester.pumpWidget(_app(repository: _FailingPlanningRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo orçamento'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Saúde');
    await tester.enterText(fields.at(1), '250,00');
    await tester.tap(find.text('Salvar orçamento'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível salvar o orçamento. Revise os dados e tente novamente.',
      ),
      findsOneWidget,
    );
    expect(find.text('Saúde'), findsOneWidget);
    expect(find.text('Novo orçamento'), findsWidgets);
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
      find.text('Assinaturas'),
      800,
      scrollable: find.byType(Scrollable).first,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Assinaturas'), findsOneWidget);
  });
}

Widget _app({InMemoryPlanningRepository? repository}) => ProviderScope(
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
);

class _FailingPlanningRepository extends InMemoryPlanningRepository {
  _FailingPlanningRepository();

  @override
  Future<void> addBudget(Budget budget) async {
    throw StateError('simulated write failure');
  }
}

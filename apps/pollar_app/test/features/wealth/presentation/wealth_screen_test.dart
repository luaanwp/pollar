import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/wealth/data/in_memory_wealth_repository.dart';
import 'package:pollar_app/features/wealth/domain/wealth_goal.dart';
import 'package:pollar_app/features/wealth/presentation/wealth_controller.dart';
import 'package:pollar_app/features/wealth/presentation/wealth_screen.dart';

import '../../../support/wealth_fixture.dart';

void main() {
  testWidgets('shows reconciled net worth and priority goal dossier', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Patrimônio'), findsOneWidget);
    expect(_moneySemantics('saldo, BRL R\$ 515.000,00'), findsOneWidget);
    expect(_moneySemantics('saldo, BRL R\$ 645.000,00'), findsWidgets);
    expect(_moneySemantics('dívida, BRL R\$ 130.000,00'), findsWidgets);
    expect(_moneySemantics('BRL R\$ 30.000,00'), findsWidgets);
    expect(_moneySemantics('entrada, BRL R\$ 30.000,00'), findsNothing);
    expect(find.text('Reserva de emergência'), findsWidgets);
    expect(find.text('41%'), findsOneWidget);
  });

  testWidgets('validates a goal before saving', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova meta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar meta'));
    await tester.pumpAndSettle();

    expect(
      find.text('Informe um nome para identificar o item.'),
      findsOneWidget,
    );
    expect(find.text('Informe o valor.'), findsOneWidget);
  });

  testWidgets('keeps goal fields when persistence fails', (tester) async {
    await tester.pumpWidget(_app(repository: _FailingWealthRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova meta'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Casa própria');
    await tester.enterText(fields.at(1), '100.000,00');
    await tester.tap(find.text('Salvar meta'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível salvar a meta. Revise os dados e tente novamente.',
      ),
      findsOneWidget,
    );
    expect(find.text('Casa própria'), findsOneWidget);
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
      find.text('Composição do patrimônio'),
      500,
      scrollable: find.byType(Scrollable).first,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Composição do patrimônio'), findsOneWidget);
  });

  testWidgets('opens priority goal editing with preserved values', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    final edit = find.text('Atualizar meta').first;
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();

    expect(find.text('Atualizar meta'), findsWidgets);
    expect(find.text('Reserva de emergência'), findsWidgets);
    final values = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .map((field) => field.controller.text);
    expect(
      values,
      containsAll(['Reserva de emergência', 'R\$ 30.000,00', 'R\$ 12.500,00']),
    );
  });

  testWidgets('completes the priority goal after confirmation', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = createWealthFixtureRepository();
    await tester.pumpWidget(_app(repository: repository));
    await tester.pumpAndSettle();

    final complete = find.text('Concluir meta').first;
    await tester.ensureVisible(complete);
    await tester.tap(complete);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluir meta').last);
    await tester.pumpAndSettle();

    expect(
      (await repository.listGoals())
          .singleWhere((item) => item.name == 'Reserva de emergência')
          .completed,
      isTrue,
    );
  });
}

Finder _moneySemantics(String label) => find.byWidgetPredicate(
  (widget) => widget is Text && widget.semanticsLabel == label,
);

Widget _app({InMemoryWealthRepository? repository}) => ProviderScope(
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
    theme: PollarTheme.light(),
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

class _FailingWealthRepository extends InMemoryWealthRepository {
  _FailingWealthRepository();

  @override
  Future<void> addGoal(WealthGoal goal) async {
    throw StateError('simulated write failure');
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/statements/presentation/card_statement_screen.dart';
import 'package:pollar_app/features/statements/presentation/statement_controller.dart';

import '../../../support/statement_fixture.dart';

void main() {
  testWidgets('shows reconciled statement and installment evidence', (
    tester,
  ) async {
    await tester.pumpWidget(_app(StatementFixtureDataSource()));
    await tester.pumpAndSettle();

    expect(find.text('Cartão Ouro'), findsOneWidget);
    expect(find.text(r'R$ 555,63'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Mercado do bairro'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Mercado do bairro'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('Pagar fatura'), findsOneWidget);
  });

  testWidgets('supports 200 percent text without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(_app(StatementFixtureDataSource()));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Compras da fatura'), findsOneWidget);
  });

  testWidgets('shows validation when payment exceeds statement balance', (
    tester,
  ) async {
    await tester.pumpWidget(_app(StatementFixtureDataSource()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pagar fatura'));
    await tester.pumpAndSettle();
    final input = find.descendant(
      of: find.byKey(const Key('statement-payment-amount')),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(input, '9999,00');
    await tester.tap(find.byKey(const Key('confirm-statement-payment')));
    await tester.pumpAndSettle();
    expect(
      find.text('O pagamento não pode superar o saldo da fatura.'),
      findsOneWidget,
    );
    expect(find.text('Registrar pagamento da fatura?'), findsOneWidget);
  });
}

Widget _app(StatementFixtureDataSource source) => ProviderScope(
  overrides: [
    statementDataSourceProvider.overrideWithValue(source),
    statementClockProvider.overrideWithValue(() => statementFixtureNow),
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
    home: const Scaffold(body: CardStatementScreen(cardId: 'card')),
  ),
);

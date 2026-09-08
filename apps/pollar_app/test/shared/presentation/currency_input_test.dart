import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/shared/presentation/currency_input.dart';

void main() {
  testWidgets(
    'edits invalidate stale money and preview, and reset restores value',
    (tester) async {
      final form = GlobalKey<FormState>();
      Money? latest;
      await tester.pumpWidget(
        MaterialApp(
          theme: PollarTheme.light(),
          home: Scaffold(
            body: Form(
              key: form,
              child: CurrencyInput(
                label: 'Valor',
                currency: Currency.brl,
                installments: 3,
                initialValue: const Money(
                  minorUnits: 10000,
                  currency: Currency.brl,
                ),
                onChanged: (value) => latest = value,
              ),
            ),
          ),
        ),
      );
      expect(
        find.textContaining('1 × R\$ 33,34 + 2 × R\$ 33,33'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextFormField), r'R$ 1.234,56');
      await tester.pump();
      expect(latest?.minorUnits, 123456);
      expect(form.currentState!.validate(), isTrue);
      await tester.enterText(find.byType(TextFormField), '1.23');
      await tester.pump();
      expect(latest, isNull);
      expect(find.textContaining('Parcelas:'), findsNothing);
      expect(form.currentState!.validate(), isFalse);
      form.currentState!.reset();
      await tester.pump();
      expect(latest?.minorUnits, 10000);
      expect(find.textContaining('1 × R\$ 33,34'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();
      expect(latest, isNull);
      expect(form.currentState!.validate(), isFalse);
    },
  );
}

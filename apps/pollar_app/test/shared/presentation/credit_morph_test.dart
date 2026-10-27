import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/shared/presentation/money_text.dart';
import 'package:pollar_app/shared/presentation/pollar_credit_surface.dart';
import 'package:pollar_app/shared/presentation/pollar_motion.dart';

void main() {
  Widget face(double width) => PollarCardMorph(
    tag: 'credit',
    creditIdentity: true,
    child: SizedBox(
      width: width,
      height: 180,
      child: const PollarCreditSurface(
        child: MoneyText(Money(minorUnits: 12345, currency: Currency.brl)),
      ),
    ),
  );

  testWidgets(
    'credit morph carries only solid identity between real route endpoints',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PollarTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  face(240),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(body: face(400)),
                      ),
                    ),
                    child: const Text('Abrir fatura'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abrir fatura'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final shuttle = find.byWidgetPredicate(
        (widget) =>
            widget is Material &&
            widget.color == PollarColors.light.creditSurface,
      );
      expect(shuttle, findsOneWidget);
      expect(
        find.descendant(of: shuttle, matching: find.byType(MoneyText)),
        findsNothing,
      );
      expect(
        find.descendant(of: shuttle, matching: find.byType(Icon)),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
      expect(shuttle, findsNothing);
      expect(find.byType(MoneyText), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('credit morph is cut immediately for reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PollarTheme.dark(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(body: face(300)),
        ),
      ),
    );
    expect(find.byType(Hero), findsNothing);
    expect(find.byType(MoneyText), findsOneWidget);
  });
}

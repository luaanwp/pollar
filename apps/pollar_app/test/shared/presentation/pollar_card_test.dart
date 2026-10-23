import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/shared/presentation/pollar_card.dart';

void main() {
  Widget app(Widget child) => MaterialApp(
    theme: PollarTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('legacy outlined card remains the default', (tester) async {
    await tester.pumpWidget(app(const PollarCard(child: Text('Original'))));
    final card = tester.widget<Card>(find.byType(Card));
    expect(card.color, PollarColors.light.canvas);
    expect(
      (card.shape! as RoundedRectangleBorder).side.color,
      PollarColors.light.border,
    );
    expect((card.shape! as RoundedRectangleBorder).side.width, 1);
    expect(card.elevation, 0);
  });

  for (final variant in [PollarCardVariant.flat, PollarCardVariant.financial]) {
    testWidgets('$variant is borderless when informational', (tester) async {
      await tester.pumpWidget(
        app(PollarCard(variant: variant, child: const Text('Grupo'))),
      );
      final card = tester.widget<Card>(find.byType(Card));
      expect((card.shape! as RoundedRectangleBorder).side, BorderSide.none);
      expect(
        card.color,
        variant == PollarCardVariant.financial
            ? PollarColors.light.financialSurface
            : PollarColors.light.canvas,
      );
      expect(card.elevation, 0);
    });
    testWidgets(
      '$variant preserves interactive boundary, focus and keyboard action',
      (tester) async {
        var activations = 0;
        await tester.pumpWidget(
          app(
            PollarCard(
              variant: variant,
              onTap: () => activations++,
              child: const Text('Abrir grupo'),
            ),
          ),
        );
        var shape =
            tester.widget<Card>(find.byType(Card)).shape!
                as RoundedRectangleBorder;
        expect(shape.side.width, 1);
        final ink = tester.widget<InkWell>(find.byType(InkWell));
        expect(ink.canRequestFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        shape =
            tester.widget<Card>(find.byType(Card)).shape!
                as RoundedRectangleBorder;
        expect(shape.side.color, PollarColors.light.info);
        expect(shape.side.width, 2);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(activations, 1);
      },
    );
  }
}

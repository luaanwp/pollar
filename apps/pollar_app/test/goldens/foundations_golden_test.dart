import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/design_system/presentation/foundations_catalog.dart';
import 'package:pollar_app/shared/presentation/pollar_card.dart';
import 'package:pollar_app/shared/presentation/money_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Future.wait([
      (FontLoader('Inter')
            ..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf')))
          .load(),
      (FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(
            rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
          ))
          .load(),
    ]);
  });

  for (final dark in [false, true]) {
    for (final width in [320.0, 390.0, 1440.0]) {
      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets('foundations $width dark=$dark scale=$scale', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          try {
            tester.view.physicalSize = Size(width, 1100);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: dark ? PollarTheme.dark() : PollarTheme.light(),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: Size(width, 1100),
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: Scaffold(
                    body: Center(
                      child: SizedBox(
                        width: 720,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: const [FoundationsCatalog()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.bySemanticsLabel(RegExp('saldo, BRL')), findsWidgets);
            if (width == 320 && scale == 1.3) {
              expect(
                tester
                    .widget<MoneyText>(find.byType(MoneyText).first)
                    .allowGroupBreaks,
                isFalse,
              );
            }
            if (width == 320 && scale == 2) {
              expect(
                tester
                    .widget<MoneyText>(find.byType(MoneyText).first)
                    .allowGroupBreaks,
                isTrue,
              );
            }
            if (scale == 1 || scale == 2 || (width == 320 && scale == 1.3)) {
              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile(
                  'foundations_${width.toInt()}_${dark ? 'dark' : 'light'}_${scale == 1.3 ? '130pct' : '${scale.toInt()}x'}.png',
                ),
              );
            }
            final visibleSize = tester.getSize(find.byType(PollarCard).first);
            await tester.tap(find.byTooltip('Ocultar valores de exemplo'));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(
              find.byTooltip('Mostrar valores de exemplo'),
              findsOneWidget,
            );
            expect(tester.getSize(find.byType(PollarCard).first), visibleSize);
            expect(find.bySemanticsLabel(RegExp('saldo, BRL')), findsNothing);
            expect(find.textContaining('1.234'), findsNothing);
            expect(
              find.bySemanticsLabel(
                RegExp('Valor oculto pelo modo privacidade'),
              ),
              findsWidgets,
            );
            if ((width == 390 && scale == 1) ||
                (width == 320 && scale == 1.3)) {
              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile(
                  'foundations_${width.toInt()}_${dark ? 'dark' : 'light'}_${scale == 1.3 ? '130pct_' : ''}hidden.png',
                ),
              );
            }
          } finally {
            semantics.dispose();
          }
        });
      }
    }
  }

  test(
    'new balance scale is explicit and does not change legacy amountHero',
    () {
      expect(PollarTypography.amountHero.fontSize, 34);
      expect(PollarTypography.balanceHeroForWidth(599).fontSize, 34);
      expect(PollarTypography.balanceHeroForWidth(600).fontSize, 40);
      expect(
        PollarTypography.balanceHero.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(
        PollarTypography.balanceHeroCompact.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
    },
  );
}

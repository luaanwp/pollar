import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/accessibility_polish_fixture.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'))).load();
    await (FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(
          rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
        ))
        .load();
  });

  void viewport(WidgetTester tester, Size size, [double scale = 1]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    final old = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy = old);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  for (final dark in [false, true]) {
    testWidgets('control states and keyboard focus dark=$dark', (tester) async {
      viewport(tester, const Size(720, 900));
      final primary = FocusNode();
      final ghost = FocusNode();
      addTearDown(primary.dispose);
      addTearDown(ghost.dispose);
      await tester.pumpWidget(
        polishApp(
          dark: dark,
          child: PolishControlGallery(primaryFocus: primary, ghostFocus: ghost),
        ),
      );
      (dark ? ghost : primary).requestFocus();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'polish_controls_720_${dark ? 'dark' : 'light'}_focus.png',
        ),
      );
    });
  }
  testWidgets('compact large-text control states', (tester) async {
    viewport(tester, const Size(320, 1000), 2);
    final primary = FocusNode();
    final ghost = FocusNode();
    addTearDown(primary.dispose);
    addTearDown(ghost.dispose);
    await tester.pumpWidget(
      polishApp(
        dark: true,
        child: PolishControlGallery(primaryFocus: primary, ghostFocus: ghost),
      ),
    );
    await tester.scrollUntilVisible(find.text('Discreto'), 200);
    ghost.requestFocus();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('polish_controls_320_dark_200.png'),
    );
  });
  testWidgets('complete recovery action at 200 percent', (tester) async {
    viewport(tester, const Size(320, 600), 2);
    await tester.pumpWidget(polishApp(child: polishRecovery()));
    await tester.scrollUntilVisible(
      find.text('Carregar informações novamente'),
      100,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('polish_recovery_320_200.png'),
    );
  });
  for (final wide in [false, true]) {
    testWidgets('modal keyboard focus wide=$wide', (tester) async {
      viewport(tester, wide ? const Size(1200, 900) : const Size(390, 844));
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        polishApp(dark: wide, child: polishModalLauncher(focus)),
      );
      await tester.tap(find.text('Abrir confirmação'));
      await tester.pumpAndSettle();
      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(
        tester
            .getSize(find.widgetWithText(TextButton, 'Confirmar alteração'))
            .height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          wide
              ? 'polish_dialog_1200_dark_focus.png'
              : 'polish_sheet_390_light_focus.png',
        ),
      );
    });
  }
}

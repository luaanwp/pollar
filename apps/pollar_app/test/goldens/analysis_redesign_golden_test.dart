import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/analysis_redesign_fixture.dart';

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

  Future<void> capture(
    WidgetTester tester,
    String name, {
    required bool wealth,
    Size size = const Size(390, 844),
    double scale = 1,
    bool dark = false,
    bool hidden = false,
    bool long = false,
    bool empty = false,
    String? section,
    bool basis = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      analysisRedesignApp(
        wealth: wealth,
        dark: dark,
        hidden: hidden,
        long: long,
        empty: empty,
        reduced: true,
      ),
    );
    await tester.pumpAndSettle();
    if (basis) {
      await tester.tap(find.text('Base confirmada'));
      await tester.pumpAndSettle();
    }
    if (section != null) {
      final target = find.text(section);
      for (var step = 0; step < 40 && target.evaluate().isEmpty; step++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
        await tester.pumpAndSettle();
      }
      expect(target, findsWidgets);
      await tester.ensureVisible(target.first);
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(name));
  }

  testWidgets(
    'reports dark desktop',
    (tester) => capture(
      tester,
      'reports_1200_dark.png',
      wealth: false,
      size: const Size(1200, 1000),
      dark: true,
    ),
  );
  testWidgets(
    'reports expanded basis compact',
    (tester) =>
        capture(tester, 'reports_390_basis.png', wealth: false, basis: true),
  );
  testWidgets(
    'reports long table at 200 percent',
    (tester) => capture(
      tester,
      'reports_320_long_table_200.png',
      wealth: false,
      size: const Size(320, 1000),
      scale: 2,
      long: true,
      section: 'abr. 2026',
    ),
  );
  testWidgets(
    'reports long categories intermediate',
    (tester) => capture(
      tester,
      'reports_640_long_categories_130.png',
      wealth: false,
      size: const Size(640, 1000),
      scale: 1.3,
      long: true,
      section: 'Composição das saídas',
    ),
  );
  testWidgets(
    'wealth dark desktop',
    (tester) => capture(
      tester,
      'wealth_1200_dark.png',
      wealth: true,
      size: const Size(1200, 1000),
      dark: true,
    ),
  );
  testWidgets(
    'wealth private compact',
    (tester) =>
        capture(tester, 'wealth_390_private.png', wealth: true, hidden: true),
  );
  testWidgets(
    'wealth private goal register',
    (tester) => capture(
      tester,
      'wealth_390_goals_private_dark.png',
      wealth: true,
      hidden: true,
      dark: true,
      section: 'Metas acompanhadas',
    ),
  );
  testWidgets(
    'wealth long register at 200 percent',
    (tester) => capture(
      tester,
      'wealth_320_long_register_200.png',
      wealth: true,
      size: const Size(320, 1000),
      scale: 2,
      long: true,
      section: 'Composição do patrimônio',
    ),
  );
  testWidgets(
    'wealth long goal intermediate',
    (tester) => capture(
      tester,
      'wealth_640_long_goal_130.png',
      wealth: true,
      size: const Size(640, 1000),
      scale: 1.3,
      long: true,
      section: 'Meta prioritária',
    ),
  );
  testWidgets(
    'wealth empty compact',
    (tester) =>
        capture(tester, 'wealth_390_empty.png', wealth: true, empty: true),
  );
}

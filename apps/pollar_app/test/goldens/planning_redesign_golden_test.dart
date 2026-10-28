import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/planning_redesign_fixture.dart';

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
    Size size = const Size(390, 844),
    double scale = 1,
    bool dark = false,
    bool hidden = false,
    bool long = false,
    bool empty = false,
    String? section,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      planningRedesignApp(
        dark: dark,
        hidden: hidden,
        long: long,
        empty: empty,
        reduced: true,
      ),
    );
    await tester.pumpAndSettle();
    if (section != null) {
      await tester.scrollUntilVisible(
        find.text(section),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(name));
  }

  testWidgets(
    'planning desktop dark',
    (tester) => capture(
      tester,
      'planning_1200_dark.png',
      size: const Size(1200, 900),
      dark: true,
    ),
  );
  testWidgets(
    'planning compact private',
    (tester) => capture(tester, 'planning_390_private.png', hidden: true),
  );
  testWidgets(
    'planning budgets dark private',
    (tester) => capture(
      tester,
      'planning_390_budgets_private_dark.png',
      hidden: true,
      dark: true,
      section: 'Orçamentos por categoria',
    ),
  );
  testWidgets(
    'planning long values intermediate',
    (tester) => capture(
      tester,
      'planning_640_long_130.png',
      size: const Size(640, 1000),
      scale: 1.3,
      long: true,
    ),
  );
  testWidgets(
    'planning long budgets at 200 percent',
    (tester) => capture(
      tester,
      'planning_320_long_budgets_200.png',
      size: const Size(320, 900),
      scale: 2,
      long: true,
      section: 'Orçamentos por categoria',
    ),
  );
  testWidgets(
    'planning empty compact',
    (tester) => capture(tester, 'planning_390_empty.png', empty: true),
  );
}

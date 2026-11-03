import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/features/planning/domain/recurring_rule.dart';

import '../support/mobile_adaptation_fixture.dart';
import '../support/mobile_shell_fixture.dart';

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

  void viewport(WidgetTester tester, Size size, double scale) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> form(
    WidgetTester tester,
    String name,
    String golden, {
    Size size = const Size(390, 844),
    double scale = 1,
    double ime = 280,
    bool dark = false,
  }) async {
    viewport(tester, size, scale);
    await tester.pumpWidget(MobileFormHarness(dark: dark, reduced: true));
    await tester.ensureVisible(find.text(name));
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
    if (name == 'Orçamento') {
      await tester.enterText(find.byType(TextFormField).first, 'Saúde');
      await tester.ensureVisible(find.byType(TextFormField).at(1));
      await tester.enterText(find.byType(TextFormField).at(1), '250,00');
    }
    tester.view.viewInsets = FakeViewPadding(bottom: ime);
    tester.view.padding = FakeViewPadding(top: 24, bottom: ime > 0 ? 0 : 34);
    await tester.pumpAndSettle();
    final save = mobileFormActions[name]!;
    await tester.scrollUntilVisible(
      find.text(save),
      120,
      scrollable: find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(
      tester.getBottomLeft(find.widgetWithText(TextButton, save)).dy,
      lessThanOrEqualTo(size.height - ime),
    );
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
  }

  testWidgets(
    'budget with simulated IME light',
    (tester) => form(tester, 'Orçamento', 'mobile_budget_390_ime_light.png'),
  );
  testWidgets(
    'budget with simulated IME dark',
    (tester) =>
        form(tester, 'Orçamento', 'mobile_budget_390_ime_dark.png', dark: true),
  );
  testWidgets(
    'recurring with simulated IME at 200 percent',
    (tester) => form(
      tester,
      'Compromisso',
      'mobile_recurring_320_ime_200.png',
      size: const Size(320, 900),
      scale: 2,
    ),
  );
  testWidgets(
    'goal with simulated IME at 200 percent',
    (tester) => form(
      tester,
      'Meta',
      'mobile_goal_390_ime_200.png',
      scale: 2,
      dark: true,
    ),
  );
  testWidgets(
    'landscape short sheet with simulated IME',
    (tester) => form(
      tester,
      'Orçamento',
      'mobile_budget_844_landscape_ime.png',
      size: const Size(844, 390),
      scale: 2,
      ime: 150,
    ),
  );
  testWidgets('confirmation respects gesture inset', (tester) async {
    viewport(tester, const Size(390, 844), 1);
    await tester.pumpWidget(const MobileFormHarness(reduced: true));
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('mobile_confirmation_390_safe.png'),
    );
  });
  testWidgets('native large-text recurring selector', (tester) async {
    viewport(tester, const Size(320, 900), 2);
    await tester.pumpWidget(const MobileFormHarness(reduced: true));
    await tester.tap(find.text('Compromisso'));
    await tester.pumpAndSettle();
    final selector = find.byType(DropdownButtonFormField<RecurringKind>);
    await tester.ensureVisible(selector);
    await tester.tap(selector);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('mobile_recurring_320_selector_200.png'),
    );
  });
  for (final landscape in [false, true]) {
    testWidgets('shell safe area landscape=$landscape', (tester) async {
      viewport(
        tester,
        landscape ? const Size(844, 390) : const Size(390, 844),
        landscape ? 1 : 2,
      );
      if (landscape) {
        tester.view.padding = const FakeViewPadding(
          left: 44,
          right: 34,
          top: 24,
          bottom: 21,
        );
        tester.view.viewPadding = const FakeViewPadding(
          left: 44,
          right: 34,
          top: 24,
          bottom: 21,
        );
      }
      final router = createMobileShellRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(mobileShellApp(router, dark: !landscape));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          landscape
              ? 'mobile_shell_844_landscape_safe.png'
              : 'mobile_shell_390_safe_dark_200.png',
        ),
      );
    });
  }
}

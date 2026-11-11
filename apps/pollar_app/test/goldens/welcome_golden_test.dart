import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/auth/presentation/welcome_screen.dart';

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

  for (final sample in [
    (
      name: 'welcome_390_dark',
      size: const Size(390, 741),
      dark: true,
      reduced: false,
    ),
    (
      name: 'welcome_390_light',
      size: const Size(390, 844),
      dark: false,
      reduced: false,
    ),
    (
      name: 'welcome_1440_dark',
      size: const Size(1440, 900),
      dark: true,
      reduced: false,
    ),
    (
      name: 'welcome_1440_light',
      size: const Size(1440, 900),
      dark: false,
      reduced: false,
    ),
  ]) {
    testWidgets(sample.name, (tester) async {
      await _mount(
        tester,
        size: sample.size,
        dark: sample.dark,
        reduced: sample.reduced,
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('${sample.name}.png'),
      );
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('reduced motion paints the settled composition on frame zero', (
    tester,
  ) async {
    await _mount(tester, size: const Size(390, 741), dark: true, reduced: true);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('welcome_390_dark.png'),
    );
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ledger has a distinct intermediate frame with usable entry', (
    tester,
  ) async {
    await _mount(
      tester,
      size: const Size(390, 741),
      dark: true,
      reduced: false,
    );
    await tester.pump(const Duration(milliseconds: 160));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('welcome_390_dark_frame160.png'),
    );
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('welcome-enter')))
          .onPressed,
      isNotNull,
    );
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _mount(
  WidgetTester tester, {
  required Size size,
  required bool dark,
  required bool reduced,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dark ? PollarTheme.dark() : PollarTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
        child: child!,
      ),
      home: const WelcomeScreen(),
    ),
  );
}

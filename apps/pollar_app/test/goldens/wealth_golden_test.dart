import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/wealth_golden_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'));
    final lucide = FontLoader('packages/lucide_icons_flutter/Lucide')
      ..addFont(
        rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
      );
    await Future.wait([inter.load(), lucide.load()]);
  });

  Future<void> render(WidgetTester tester, Size size, String golden) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wealthGoldenApp());
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
  }

  testWidgets(
    'wealth compact 390x844',
    (tester) => render(tester, const Size(390, 844), 'wealth_390x844.png'),
  );

  testWidgets(
    'wealth wide 1200x900',
    (tester) => render(tester, const Size(1200, 900), 'wealth_1200x900.png'),
  );

  testWidgets('wealth goal form wide dark', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wealthGoldenApp(dark: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova meta'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('wealth_goal_dark_1200x900.png'),
    );
  });

  testWidgets('wealth compact at 200 percent text', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(wealthGoldenApp());
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('wealth_text_200_390x844.png'),
    );
  });

  testWidgets('wealth management wide', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wealthGoldenApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Gerenciar registros'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('wealth_management_1200x900.png'),
    );
  });

  testWidgets('wealth pause confirmation compact', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wealthGoldenApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Gerenciar registros'),
      900,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Pausar').first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pausar').first);
    await tester.pumpAndSettle();
    expect(find.text('Pausar meta?'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('wealth_pause_confirmation_390x844.png'),
    );
  });
}

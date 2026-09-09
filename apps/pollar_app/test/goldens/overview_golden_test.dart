import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/main.dart';
import 'package:pollar_app/features/overview/presentation/overview_controller.dart';

import '../support/overview_fixture.dart';

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

  Future<void> renderOverview(
    WidgetTester tester, {
    required Size size,
    required String golden,
    bool privacyHidden = false,
    bool dark = false,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          overviewDataSourceProvider.overrideWithValue(
            const OverviewFixtureDataSource(),
          ),
          overviewClockProvider.overrideWithValue(() => overviewFixtureNow),
        ],
        child: const PollarApp(),
      ),
    );
    await tester.pumpAndSettle();
    if (privacyHidden) {
      await tester.tap(find.byTooltip('Ocultar valores'));
      await tester.pumpAndSettle();
    }
    if (dark) {
      await tester.tap(find.byTooltip('Tema escuro'));
      await tester.pumpAndSettle();
    }

    await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
  }

  testWidgets('overview compact 390x844', (tester) async {
    await renderOverview(
      tester,
      size: const Size(390, 844),
      golden: 'overview_390x844.png',
    );
  });

  testWidgets('overview wide 1440x900', (tester) async {
    await renderOverview(
      tester,
      size: const Size(1440, 900),
      golden: 'overview_1440x900.png',
    );
  });

  testWidgets('overview compact privacy 390x844', (tester) async {
    await renderOverview(
      tester,
      size: const Size(390, 844),
      golden: 'overview_privacy_390x844.png',
      privacyHidden: true,
    );
  });

  testWidgets('overview wide dark 1440x900', (tester) async {
    await renderOverview(
      tester,
      size: const Size(1440, 900),
      golden: 'overview_dark_1440x900.png',
      dark: true,
    );
  });

  testWidgets('overview wide 200 percent text 1200x1000', (tester) async {
    await renderOverview(
      tester,
      size: const Size(1200, 1000),
      golden: 'overview_text_1200x1000.png',
      textScale: 2,
    );
  });
}

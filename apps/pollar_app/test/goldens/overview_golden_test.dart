import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/main.dart';

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
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: PollarApp()));
    await tester.pumpAndSettle();

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
}

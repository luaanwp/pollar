import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/design_system/presentation/motion_catalog.dart';
import 'package:pollar_app/shared/presentation/pollar_kinetic_card.dart';

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

  Future<void> mount(
    WidgetTester tester, {
    bool dark = false,
    bool reduced = false,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('motion-frame'),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? PollarTheme.dark() : PollarTheme.light(),
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: const MotionCatalog(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('motion sample records rolling, morphing and card flip frames', (
    tester,
  ) async {
    await mount(tester);
    const export = bool.fromEnvironment('POLLAR_EXPORT_MOTION');
    if (export) Directory('build/motion-preview').createSync(recursive: true);
    for (var frame = 0; frame < 32; frame++) {
      if (frame == 4) await tester.tap(find.text('Atualizar amostra'));
      if (frame == 12) {
        await tester.tap(find.byTooltip('Virar cartão demonstrativo'));
      }
      if (frame == 24) await tester.tap(find.byTooltip('Voltar à frente'));
      await tester.pump(const Duration(milliseconds: 50));
      if (frame == 7 || frame == 15) {
        await expectLater(
          find.byKey(const Key('motion-frame')),
          matchesGoldenFile('motion_390_light_frame_$frame.png'),
        );
      }
      if (export) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('motion-frame')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File(
            'build/motion-preview/frame-${frame.toString().padLeft(2, '0')}.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'desktop pointer tilt and chart morph retain the current layout',
    (tester) async {
      await mount(tester, dark: true, size: const Size(1440, 1000));
      await tester.tap(find.text('Atualizar amostra'));
      final pointer = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      await pointer.addPointer(location: Offset.zero);
      final target = tester.getRect(
        find.byTooltip('Virar cartão demonstrativo'),
      );
      await pointer.moveTo(target.center - const Offset(20, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final transforms = tester.widgetList<Transform>(
        find.descendant(
          of: find.byType(PollarKineticCard),
          matching: find.byType(Transform),
        ),
      );
      expect(
        transforms.any(
          (transform) =>
              transform.transform.entry(0, 2).abs() > 0.0001 ||
              transform.transform.entry(1, 2).abs() > 0.0001,
        ),
        isTrue,
      );
      await expectLater(
        find.byKey(const Key('motion-frame')),
        matchesGoldenFile('motion_1440_dark_tilt.png'),
      );
      await pointer.removePointer();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('motion sample dark reduced mode is immediately usable', (
    tester,
  ) async {
    await mount(tester, dark: true, reduced: true);
    await tester.tap(find.text('Atualizar amostra'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Virar cartão demonstrativo'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('motion-frame')),
      matchesGoldenFile('motion_390_dark_reduced_back.png'),
    );
    expect(tester.takeException(), isNull);
  });
}

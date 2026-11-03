import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/accounts/presentation/account_form_screen.dart';
import 'package:pollar_app/shared/presentation/pollar_motion.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'account route covers previous page throughout push/pop dark=$dark',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const ColoredBox(color: Color(0xFFFF00FF)),
              routes: [
                GoRoute(
                  path: 'new',
                  pageBuilder: (context, state) => pollarMotionPage<void>(
                    context: context,
                    key: state.pageKey,
                    child: const AccountFormScreen(),
                  ),
                ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);
        final theme = (dark ? PollarTheme.dark() : PollarTheme.light())
            .copyWith(platform: TargetPlatform.android);
        await tester.pumpWidget(
          ProviderScope(
            child: RepaintBoundary(
              key: const Key('route-frame'),
              child: MaterialApp.router(
                theme: theme,
                routerConfig: router,
                locale: const Locale('pt', 'BR'),
                supportedLocales: const [Locale('pt', 'BR')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final background = theme.extension<PollarColors>()!.background;
        router.push('/new');
        await tester.pumpAndSettle();
        await _expectBackground(tester, background);
        await tester.enterText(
          find.byKey(const Key('account-name')),
          'Preservada',
        );
        router.pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await _expectBackground(tester, background);
        await tester.pumpAndSettle();
        await _expectBackground(tester, const Color(0xFFFF00FF));
        router.push('/new');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 40));
        await _expectBackground(tester, background);
        await tester.pump(const Duration(milliseconds: 90));
        await _expectBackground(tester, background);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> _expectBackground(WidgetTester tester, Color expected) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('route-frame')),
    );
    final image = await boundary.toImage();
    final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    // The form has no Scaffold: these pixels used to expose the previous page.
    for (final point in [const Offset(2, 2), const Offset(388, 300)]) {
      final offset = (point.dy.toInt() * image.width + point.dx.toInt()) * 4;
      expect(
        Color.fromARGB(
          255,
          data.getUint8(offset),
          data.getUint8(offset + 1),
          data.getUint8(offset + 2),
        ),
        expected,
      );
    }
    image.dispose();
  });
}

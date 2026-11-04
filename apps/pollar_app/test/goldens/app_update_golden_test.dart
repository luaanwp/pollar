import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/app/routing/app_router.dart';
import 'package:pollar_app/main.dart';
import 'package:pollar_app/features/updates/presentation/app_update_controller.dart';
import 'package:pollar_app/features/updates/presentation/app_update_widgets.dart';

import '../features/updates/app_update_controller_test.dart' show FakeUpdates;

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
  for (final keyboard in [false, true]) {
    testWidgets('update shell respects available body keyboard=$keyboard', (
      tester,
    ) async {
      tester.view.physicalSize = keyboard
          ? const Size(320, 600)
          : const Size(720, 360);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = FakeViewPadding(bottom: keyboard ? 260 : 0);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final container = ProviderContainer(
        overrides: [appUpdateGatewayProvider.overrideWithValue(FakeUpdates())],
      );
      addTearDown(container.dispose);
      await container.read(appUpdateProvider.notifier).check();
      container.read(routerProvider).go('/accounts/new');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const PollarApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Nova versão disponível'),
        keyboard ? findsNothing : findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'app_update_shell_${keyboard ? 'keyboard_320' : 'landscape_720'}.png',
        ),
      );
    });
  }
  for (final compact in [true, false]) {
    testWidgets('update availability and canceled install compact=$compact', (
      tester,
    ) async {
      tester.view.physicalSize = compact
          ? const Size(320, 844)
          : const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = compact ? 2 : 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final gateway = FakeUpdates();
      final container = ProviderContainer(
        overrides: [appUpdateGatewayProvider.overrideWithValue(gateway)],
      );
      addTearDown(container.dispose);
      await container.read(appUpdateProvider.notifier).check();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: compact ? PollarTheme.dark() : PollarTheme.light(),
            home: const Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: AppUpdatePanel(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nova versão disponível'), findsOneWidget);
      expect(gateway.installs, 0);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'app_update_${compact ? '320_dark_200' : '1200_light'}.png',
        ),
      );
      await tester.tap(find.text('Atualizar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Instalar atualização'));
      await tester.pumpAndSettle();
      expect(find.text('Instalar atualização?'), findsOneWidget);
      await tester.ensureVisible(find.text('Agora não'));
      await tester.tap(find.text('Agora não'));
      await tester.pumpAndSettle();
      expect(gateway.installs, 0);
      expect(gateway.downloads, 1);
      expect(tester.takeException(), isNull);
    });
  }
}

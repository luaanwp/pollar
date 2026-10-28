import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pollar_app/app/routing/app_router.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/settings/presentation/settings_screen.dart';
import 'package:pollar_app/features/sync/presentation/sync_screen.dart';
import 'package:pollar_app/features/data_management/presentation/data_management_screen.dart';
import 'package:pollar_app/features/settings/presentation/more_screen.dart';
import 'package:pollar_app/main.dart';
import 'package:pollar_app/shared/presentation/pollar_motion.dart';

void main() {
  for (final sample in [
    (path: 'settings', type: SettingsScreen),
    (path: 'sync', type: SyncScreen),
    (path: 'data', type: DataManagementScreen),
  ]) {
    testWidgets(
      'real More ${sample.path} route shares motion and preserves return',
      (tester) async {
        await tester.pumpWidget(const ProviderScope(child: PollarApp()));
        await tester.pumpAndSettle();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        final router = container.read(routerProvider);
        router.go('/more/${sample.path}');
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(sample.type));
        final page = Navigator.of(context).widget.pages.last;
        expect(page, isA<CustomTransitionPage<dynamic>>());
        expect(
          (page as CustomTransitionPage).transitionDuration,
          PollarMotion.change,
        );
        router.pop();
        await tester.pumpAndSettle();
        expect(router.state.uri.path, '/more');
        expect(find.byType(MoreScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'detail factory retains native Apple pages and instant reduced motion',
    (tester) async {
      Page<void>? page;
      for (final platform in [
        TargetPlatform.iOS,
        TargetPlatform.macOS,
        TargetPlatform.android,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: PollarTheme.light().copyWith(platform: platform),
            home: Builder(
              builder: (context) {
                page = pollarMotionPage<void>(
                  context: context,
                  key: const ValueKey('detail'),
                  child: const SizedBox(),
                );
                return const SizedBox();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          page,
          platform == TargetPlatform.android
              ? isA<CustomTransitionPage<void>>()
              : isA<MaterialPage<void>>(),
        );
      }
      await tester.pumpWidget(
        MaterialApp(
          theme: PollarTheme.light().copyWith(platform: TargetPlatform.android),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                page = pollarMotionPage<void>(
                  context: context,
                  key: const ValueKey('detail'),
                  child: const SizedBox(),
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect((page as CustomTransitionPage).transitionDuration, Duration.zero);
      expect(
        (page as CustomTransitionPage).reverseTransitionDuration,
        Duration.zero,
      );
    },
  );
}

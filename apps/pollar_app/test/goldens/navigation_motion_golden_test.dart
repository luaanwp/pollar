import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/routing/app_router.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/overview/presentation/overview_controller.dart';
import 'package:pollar_app/shared/presentation/pollar_motion.dart';

import '../support/overview_fixture.dart';

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
      size: const Size(390, 844),
      dark: false,
      scale: 1.0,
      reduced: false,
      name: 'navigation_390_light_frame40.png',
    ),
    (
      size: const Size(1440, 900),
      dark: true,
      scale: 1.0,
      reduced: false,
      name: 'navigation_1440_dark_frame40.png',
    ),
    (
      size: const Size(390, 844),
      dark: true,
      scale: 1.0,
      reduced: true,
      name: 'navigation_390_dark_reduced.png',
    ),
    (
      size: const Size(320, 900),
      dark: true,
      scale: 2.0,
      reduced: false,
      name: 'navigation_320_dark_2x_frame40.png',
    ),
  ]) {
    testWidgets(sample.name, (tester) async {
      tester.view.physicalSize = sample.size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = sample.scale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final container = ProviderContainer(
        overrides: [
          overviewDataSourceProvider.overrideWithValue(
            const OverviewFixtureDataSource(),
          ),
          overviewClockProvider.overrideWithValue(() => overviewFixtureNow),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(routerProvider);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: sample.dark ? PollarTheme.dark() : PollarTheme.light(),
            routerConfig: router,
            locale: const Locale('pt', 'BR'),
            supportedLocales: const [Locale('pt', 'BR')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(disableAnimations: sample.reduced),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      router.go('/more');
      await tester.pump();
      // Allow the async router redirect to mount the branch before timing it.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      final translation = tester
          .widget<Transform>(find.byKey(const Key('pollar-branch-position')))
          .transform
          .getTranslation()
          .x;
      expect(translation, sample.reduced ? 0 : greaterThan(0));
      expect(translation, lessThan(PollarMotion.branchTravel));
      expect(find.byType(PollarBranchStack), findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(sample.name),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

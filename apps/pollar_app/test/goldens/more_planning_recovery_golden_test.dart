import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/routing/app_router.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';

import '../support/planning_redesign_fixture.dart';

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

  for (final compact in [false, true]) {
    testWidgets('More return affordance compact=$compact', (tester) async {
      _viewport(tester, compact);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);
      router.go('/more/settings');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: compact ? PollarTheme.dark() : PollarTheme.light(),
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
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Voltar para Mais'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'more_back_${compact ? '320_dark_200' : '1200_light'}.png',
        ),
      );
    });
    testWidgets('Missing account recovery compact=$compact', (tester) async {
      _viewport(tester, compact);
      await tester.pumpWidget(
        planningRedesignApp(empty: true, dark: compact, reduced: true),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Novo compromisso'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Novo compromisso'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'planning_account_required_${compact ? '320_dark_200' : '1200_light'}.png',
        ),
      );
    });
  }
}

void _viewport(WidgetTester tester, bool compact) {
  tester.view.physicalSize = compact
      ? const Size(320, 844)
      : const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = compact ? 2 : 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

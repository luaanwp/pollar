import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/routing/app_router.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';
import 'package:pollar_app/features/accounts/data/seeded_account_repository.dart';
import 'package:pollar_app/features/accounts/presentation/accounts_controller.dart';
import 'package:pollar_app/features/accounts/presentation/account_form_screen.dart';
import 'package:pollar_app/features/auth/presentation/sign_in_screen.dart';

void main() {
  const storage = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storage, (_) async => null);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storage, null);
  });
  setUpAll(() async {
    for (final font in [
      ('Inter', 'assets/fonts/inter/Inter-Regular.ttf'),
      (
        'packages/lucide_icons_flutter/Lucide',
        'packages/lucide_icons_flutter/assets/lucide.ttf',
      ),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
  });

  for (final dark in [false, true]) {
    testWidgets('centered brand login desktop dark=$dark', (tester) async {
      _size(tester, const Size(1440, 900));
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: dark ? PollarTheme.dark() : PollarTheme.light(),
            home: const SignInScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('brand_login_1440_${dark ? 'dark' : 'light'}.png'),
      );
    });
  }

  testWidgets('brand login compact keyboard and text 200 percent', (
    tester,
  ) async {
    _size(tester, const Size(390, 844));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetViewInsets);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: PollarTheme.light(),
          home: const SignInScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Receber código por e-mail'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('brand_login_390_keyboard_200.png'),
    );
  });

  for (final sample in [
    (size: const Size(390, 844), dark: false, name: '390_light'),
    (size: const Size(1200, 900), dark: true, name: '1200_dark'),
  ]) {
    testWidgets('opaque account transition ${sample.name}', (tester) async {
      _size(tester, sample.size);
      final container = ProviderContainer(
        overrides: [
          accountRepositoryProvider.overrideWithValue(
            createSeededAccountRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(routerProvider);
      router.go('/accounts');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: (sample.dark ? PollarTheme.dark() : PollarTheme.light())
                .copyWith(platform: TargetPlatform.android),
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
      router.push('/accounts/new');
      // The async redirect must mount the destination before timing its motion.
      // Zero-time pumps keep the captured animation instant deterministic.
      for (
        var attempt = 0;
        attempt < 20 && find.byType(AccountFormScreen).evaluate().isEmpty;
        attempt++
      ) {
        await tester.pump();
      }
      expect(find.byType(AccountFormScreen), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 60));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('route_account_push_${sample.name}.png'),
      );
      await tester.pumpAndSettle();
      router.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('route_account_pop_${sample.name}.png'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

void _size(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

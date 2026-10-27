import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/features/accounts/data/seeded_account_repository.dart';
import 'package:pollar_app/features/accounts/presentation/accounts_controller.dart';
import 'package:pollar_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'))).load();
    await (FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(
          rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
        ))
        .load();
  });

  Future<void> renderAccounts(
    WidgetTester tester, {
    required Size size,
    required String golden,
    bool openForm = false,
    bool dark = false,
    double textScale = 1,
    bool flipCard = false,
    bool privacyHidden = false,
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
          accountRepositoryProvider.overrideWithValue(
            createSeededAccountRepository(),
          ),
        ],
        child: const PollarApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(NavigationRail).evaluate().isNotEmpty
          ? find
                .descendant(
                  of: find.byType(NavigationRail),
                  matching: find.byTooltip('Contas'),
                )
                .first
          : find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text('Contas'),
            ),
    );
    await tester.pumpAndSettle();
    if (dark) {
      await tester.tap(find.byTooltip('Tema escuro'));
      await tester.pumpAndSettle();
    }
    if (openForm) {
      await tester.tap(find.text('Cadastrar conta ou cartão'));
      await tester.pumpAndSettle();
    }
    if (privacyHidden) {
      await tester.tap(find.byTooltip('Ocultar valores'));
      await tester.pumpAndSettle();
    }
    if (flipCard) {
      final turn = find.byTooltip('Virar Cartão Ouro');
      await tester.ensureVisible(turn);
      await tester.pumpAndSettle();
      await tester.tap(turn);
      await tester.pumpAndSettle();
    }

    await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
  }

  testWidgets('accounts compact 390x900', (tester) async {
    await renderAccounts(
      tester,
      size: const Size(390, 900),
      golden: 'accounts_390x900.png',
    );
  });

  testWidgets(
    'credit reverse compact',
    (tester) => renderAccounts(
      tester,
      size: const Size(390, 900),
      golden: 'accounts_credit_back_390.png',
      flipCard: true,
    ),
  );
  testWidgets(
    'credit reverse dark desktop',
    (tester) => renderAccounts(
      tester,
      size: const Size(1440, 900),
      golden: 'accounts_credit_back_1440_dark.png',
      flipCard: true,
      dark: true,
    ),
  );
  testWidgets(
    'credit privacy compact',
    (tester) => renderAccounts(
      tester,
      size: const Size(390, 900),
      golden: 'accounts_credit_privacy_390.png',
      privacyHidden: true,
    ),
  );

  testWidgets('accounts wide 1440x900', (tester) async {
    await renderAccounts(
      tester,
      size: const Size(1440, 900),
      golden: 'accounts_1440x900.png',
    );
  });

  testWidgets('account form compact 390x900', (tester) async {
    await renderAccounts(
      tester,
      size: const Size(390, 900),
      golden: 'account_form_390x900.png',
      openForm: true,
    );
  });

  testWidgets('account form wide 1440x900', (tester) async {
    await renderAccounts(
      tester,
      size: const Size(1440, 900),
      golden: 'account_form_1440x900.png',
      openForm: true,
    );
  });

  for (final sample in [
    (
      size: const Size(320, 844),
      scale: 1.3,
      dark: false,
      name: 'accounts_320_light_130pct.png',
    ),
    (
      size: const Size(390, 900),
      scale: 1.0,
      dark: true,
      name: 'accounts_390_dark.png',
    ),
    (
      size: const Size(390, 900),
      scale: 2.0,
      dark: false,
      name: 'accounts_390_light_2x.png',
    ),
    (
      size: const Size(800, 1000),
      scale: 1.0,
      dark: false,
      name: 'accounts_800_light.png',
    ),
    (
      size: const Size(1440, 900),
      scale: 1.0,
      dark: true,
      name: 'accounts_1440_dark.png',
    ),
    (
      size: const Size(1440, 1000),
      scale: 2.0,
      dark: false,
      name: 'accounts_1440_light_2x.png',
    ),
  ]) {
    testWidgets(sample.name, (tester) async {
      await renderAccounts(
        tester,
        size: sample.size,
        golden: sample.name,
        dark: sample.dark,
        textScale: sample.scale,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

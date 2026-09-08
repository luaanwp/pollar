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
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
    await tester.tap(find.text('Contas').first);
    await tester.pumpAndSettle();
    if (openForm) {
      await tester.tap(find.text('Cadastrar conta ou cartão'));
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
}

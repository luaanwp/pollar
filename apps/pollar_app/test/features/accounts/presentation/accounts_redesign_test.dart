import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/routing/app_router.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/accounts/data/default_accounts.dart';
import 'package:pollar_app/features/accounts/data/in_memory_account_repository.dart';
import 'package:pollar_app/features/accounts/domain/account.dart';
import 'package:pollar_app/features/accounts/presentation/accounts_controller.dart';
import 'package:pollar_app/features/accounts/presentation/accounts_screen.dart';
import 'package:pollar_app/main.dart';
import 'package:pollar_app/shared/presentation/money_text.dart';
import 'package:pollar_app/shared/presentation/privacy_amount.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'))).load();
  });

  Future<ProviderContainer> mount(
    WidgetTester tester, {
    Size size = const Size(390, 900),
    double scale = 1,
    List<Account>? accounts,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountRepositoryProvider.overrideWithValue(
            InMemoryAccountRepository(
              seed: accounts ?? createDefaultAccounts(),
            ),
          ),
        ],
        child: const PollarApp(),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container.read(routerProvider).go('/accounts');
    await tester.pumpAndSettle();
    return container;
  }

  Finder scroll() => find.descendant(
    of: find.byType(AccountsScreen),
    matching: find.byType(Scrollable),
  );

  testWidgets(
    'compact rows keep statement action visible in the first viewport',
    (tester) async {
      await mount(tester, size: const Size(390, 844));
      expect(tester.getBottomRight(find.text('Ver fatura')).dy, lessThan(764));
      expect(find.text('Saldo atual'), findsNothing);
      expect(find.text('Conta corrente · BRL'), findsOneWidget);
      expect(find.text('Cartão de crédito · BRL'), findsOneWidget);
    },
  );

  testWidgets(
    'sections use available width and keep state when rail is collapsed',
    (tester) async {
      final container = await mount(tester, size: const Size(1200, 1000));
      double accountsY() => tester
          .getTopLeft(
            find.descendant(
              of: find.byType(AccountsScreen),
              matching: find.text('Contas'),
            ),
          )
          .dy;
      double cardsY() => tester.getTopLeft(find.text('Cartões de crédito')).dy;
      expect(cardsY(), greaterThan(accountsY() + 50));
      await tester.tap(find.byTooltip('Recolher navegação'));
      await tester.pumpAndSettle();
      expect(cardsY(), closeTo(accountsY(), 1));
      expect(container.read(routerProvider).state.uri.path, '/accounts');
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      await tester.pumpAndSettle();
      expect(cardsY(), greaterThan(accountsY() + 50));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'create action grows to preserve its entire label at double text',
    (tester) async {
      final container = await mount(
        tester,
        size: const Size(320, 900),
        scale: 2,
      );
      final label = find.text('Cadastrar conta ou cartão');
      final button = find.ancestor(
        of: label,
        matching: find.byType(TextButton),
      );
      final bounds = tester.getRect(button);
      final textBounds = tester.getRect(label);
      expect(bounds.height, greaterThan(48));
      expect(textBounds.top, greaterThanOrEqualTo(bounds.top));
      expect(textBounds.bottom, lessThanOrEqualTo(bounds.bottom));
      expect(tester.widget<Text>(label).maxLines, isNull);
      await tester.tap(label);
      await tester.pumpAndSettle();
      expect(container.read(routerProvider).state.uri.path, '/accounts/new');
    },
  );

  for (final sample in [
    (size: const Size(320, 900), scale: 1.3),
    (size: const Size(390, 900), scale: 2.0),
    (size: const Size(1440, 1000), scale: 1.0),
  ]) {
    testWidgets(
      'initial values reserve privacy geometry at ${sample.size.width}/${sample.scale}',
      (tester) async {
        await mount(tester, size: sample.size, scale: sample.scale);
        List<Rect> amounts() => [
          for (final widget in tester.widgetList<PrivacyAmount>(
            find.byType(PrivacyAmount),
          ))
            tester.getRect(find.byWidget(widget)),
        ];
        final before = amounts();
        final actionBefore = tester.getRect(find.text('Ver fatura'));
        await tester.tap(find.byTooltip('Ocultar valores'));
        await tester.pumpAndSettle();
        expect(amounts(), before);
        expect(tester.getRect(find.text('Ver fatura')), actionBefore);
        expect(find.byType(MoneyText), findsNothing);
        await tester.tap(find.byTooltip('Mostrar valores'));
        await tester.pumpAndSettle();
        expect(amounts(), before);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'only archived data is identified correctly and can be restored',
    (tester) async {
      final archived = createDefaultAccounts().first.archive();
      final container = await mount(tester, accounts: [archived]);
      expect(find.text('Nenhuma conta ativa'), findsOneWidget);
      expect(find.text('Nenhuma conta cadastrada'), findsNothing);
      expect(find.text('Cadastrar primeira conta'), findsNothing);
      final restore = find.byTooltip('Restaurar ${archived.name}');
      await tester.ensureVisible(restore);
      await tester.tap(restore);
      await tester.pumpAndSettle();
      expect(find.text('Nenhuma conta ativa'), findsNothing);
      expect(
        (await container.read(accountRepositoryProvider).findById(archived.id))!
            .isArchived,
        isFalse,
      );
    },
  );

  testWidgets(
    'credit card keeps flip, private terms and the existing statement route',
    (tester) async {
      final container = await mount(tester);
      final flip = find.byTooltip('Virar Cartão Ouro');
      await tester.ensureVisible(flip);
      await tester.tap(flip);
      await tester.pumpAndSettle();
      expect(find.text('Condições do cartão'), findsOneWidget);
      await tester.tap(find.byTooltip('Ocultar valores'));
      await tester.pumpAndSettle();
      expect(find.byType(MoneyText), findsNothing);
      expect(find.text('Fecha dia 20 · vence dia 28'), findsOneWidget);
      final action = find.text('Ver fatura');
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(
        container.read(routerProvider).state.uri.path,
        '/accounts/card-gold/statement',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('large values, full names and currencies reflow at 320px/2x', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      final items = [
        Account(
          id: 'brl',
          name: 'Conta com um nome completo extenso em reais',
          type: AccountType.checking,
          currency: Currency.brl,
          openingBalance: const Money(
            minorUnits: -99999999999999,
            currency: Currency.brl,
          ),
        ),
        Account(
          id: 'usd',
          name: 'Conta com um nome completo extenso em dólares',
          type: AccountType.savings,
          currency: Currency.usd,
          openingBalance: const Money(
            minorUnits: 99999999999999,
            currency: Currency.usd,
          ),
        ),
        Account(
          id: 'credit',
          name: 'Cartão com nome muito extenso e limite elevado',
          type: AccountType.creditCard,
          currency: Currency.brl,
          openingBalance: const Money(
            minorUnits: -99999999999999,
            currency: Currency.brl,
          ),
          creditCardTerms: CreditCardTerms(
            creditLimit: const Money(
              minorUnits: 99999999999999,
              currency: Currency.brl,
            ),
            closingDay: 31,
            dueDay: 30,
          ),
        ),
      ];
      await mount(
        tester,
        size: const Size(320, 900),
        scale: 2,
        accounts: items,
      );
      for (final item in items) {
        final name = find.text(item.name);
        await tester.scrollUntilVisible(name, 300, scrollable: scroll());
        expect(tester.widget<Text>(name).maxLines, isNull);
      }
      final flip = find.byTooltip('Virar ${items.last.name}');
      await tester.ensureVisible(flip);
      await tester.pumpAndSettle();
      await tester.tap(flip);
      await tester.pumpAndSettle();
      expect(find.text('Condições do cartão'), findsOneWidget);
      for (final amount in tester.widgetList<PrivacyAmount>(
        find.byType(PrivacyAmount),
      )) {
        expect(amount.allowWrap, isTrue);
        expect(amount.reserveLayout, isTrue);
      }
      await tester.tap(find.byTooltip('Ocultar valores'));
      await tester.pumpAndSettle();
      expect(find.byType(MoneyText), findsNothing);
      expect(find.bySemanticsLabel(RegExp('999.999')), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      handle.dispose();
    }
  });
}

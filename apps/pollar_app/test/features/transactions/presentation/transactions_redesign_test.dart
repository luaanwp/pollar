import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/privacy/privacy_mode_provider.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/transactions/application/transaction_account_catalog.dart';
import 'package:pollar_app/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:pollar_app/features/transactions/domain/financial_transaction.dart';
import 'package:pollar_app/features/transactions/presentation/transactions_controller.dart';
import 'package:pollar_app/features/transactions/presentation/transactions_screen.dart';
import 'package:pollar_app/main.dart';
import 'package:pollar_app/shared/presentation/money_text.dart';
import 'package:pollar_app/shared/presentation/privacy_amount.dart';
import 'package:pollar_app/shared/presentation/transaction_tile.dart';
import 'package:pollar_app/shared/presentation/pollar_motion.dart';

void main() {
  final today = DateTime(2026, 10, 23);
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'))).load();
  });

  FinancialTransaction movement(
    String id,
    String description,
    TransactionType type, {
    int minor = 12345,
    bool canceled = false,
    String? category,
  }) => FinancialTransaction(
    id: id,
    description: description,
    type: type,
    status: canceled
        ? TransactionStatus.cancelado
        : TransactionStatus.compensado,
    amount: Money(minorUnits: minor, currency: Currency.brl),
    accountId: type == TransactionType.cardPurchase ? 'card' : 'checking',
    counterAccountId: type == TransactionType.transfer
        ? 'savings'
        : type == TransactionType.cardStatementPayment
        ? 'card'
        : null,
    occurredAt: today,
    category: category ?? 'Categoria completa do lançamento',
  );

  List<FinancialTransaction> seed() => [
    movement('income', 'Salário', TransactionType.income),
    movement('expense', 'Despesa comum', TransactionType.expense),
    movement('card', 'Compra no cartão', TransactionType.cardPurchase),
    movement('transfer', 'Reserva interna', TransactionType.transfer),
    movement(
      'payment',
      'Pagamento da fatura',
      TransactionType.cardStatementPayment,
    ),
    movement(
      'canceled',
      'Despesa cancelada',
      TransactionType.expense,
      canceled: true,
    ),
  ];

  Future<ProviderContainer> mount(
    WidgetTester tester, {
    Size size = const Size(390, 900),
    double scale = 1,
    List<FinancialTransaction>? items,
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
          transactionRepositoryProvider.overrideWithValue(
            InMemoryTransactionRepository(seed: items ?? seed()),
          ),
          transactionAccountCatalogProvider.overrideWithValue(const _Catalog()),
          transactionClockProvider.overrideWithValue(() => today),
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
                  matching: find.byTooltip('Transações'),
                )
                .first
          : find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text('Transações'),
            ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
      tester.element(find.byType(TransactionsScreen)),
    );
  }

  Finder search() => find.descendant(
    of: find.byKey(const Key('transaction-search')),
    matching: find.byType(TextFormField),
  );
  Finder scroll() => find
      .descendant(
        of: find.byType(TransactionsScreen),
        matching: find.byType(Scrollable),
      )
      .first;
  Future<void> type(WidgetTester tester, String name, String label) async {
    final chip = find.byKey(ValueKey('filter-$name'));
    if (chip.evaluate().isNotEmpty) {
      await tester.tap(chip);
    } else {
      final selector = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField,
      );
      await tester.ensureVisible(selector);
      await tester.pumpAndSettle();
      await tester.tap(selector);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
    }
    await tester.pumpAndSettle();
  }

  for (final width in [390.0, 1440.0]) {
    testWidgets('type filter preserves accounting categories at width $width', (
      tester,
    ) async {
      final container = await mount(tester, size: Size(width, 900));
      await type(tester, 'expense', 'Despesas');
      expect(find.text('Despesa comum'), findsOneWidget);
      expect(find.text('Compra no cartão'), findsOneWidget);
      expect(find.text('Despesa cancelada'), findsOneWidget);
      expect(find.text('Salário'), findsNothing);
      expect(find.text('3 transações'), findsOneWidget);
      await type(tester, 'transfer', 'Transferências');
      expect(find.text('Reserva interna'), findsOneWidget);
      expect(find.text('Pagamento da fatura'), findsOneWidget);
      expect(find.text('Compra no cartão'), findsNothing);
      expect(find.text('2 transações'), findsOneWidget);
      expect(
        (await container.read(transactionRepositoryProvider).findAll()).length,
        6,
      );
    });
  }

  testWidgets('search and type combine, with one explicit reset action', (
    tester,
  ) async {
    await mount(tester);
    await type(tester, 'expense', 'Despesas');
    await tester.enterText(search(), 'Salário');
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma transação encontrada'), findsOneWidget);
    expect(find.text('0 transações'), findsOneWidget);
    await tester.tap(find.text('Limpar busca e filtro'));
    await tester.pumpAndSettle();
    expect(find.text('6 transações'), findsOneWidget);
    expect(tester.widget<TextFormField>(search()).controller!.text, isEmpty);
    expect(find.text('Despesa cancelada'), findsOneWidget);
  });

  testWidgets(
    'desktop filtering preserves surviving row state at a new index',
    (tester) async {
      await mount(tester, size: const Size(1440, 900));
      final row = find.byKey(const ValueKey('expense'));
      final before = tester.state(row);
      await type(tester, 'expense', 'Despesas');
      expect(tester.state(row), same(before));
      await type(tester, 'all', 'Todas');
      expect(tester.state(row), same(before));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('returning filtered rows do not replay their arrival', (
    tester,
  ) async {
    await mount(tester, size: const Size(1440, 900));
    await type(tester, 'expense', 'Despesas');
    expect(find.text('Salário'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('filter-all')));
    await tester.pump();
    final row = find.byKey(const ValueKey('income'));
    final transform = find
        .descendant(of: row, matching: find.byType(Transform))
        .first;
    expect(tester.widget<Transform>(transform).transform.getTranslation().y, 0);
    await tester.pumpAndSettle();
    expect(find.text('Salário'), findsOneWidget);
  });

  testWidgets(
    'a changing detail reveals only the current selection and respects privacy immediately',
    (tester) async {
      final container = await mount(
        tester,
        size: const Size(1440, 900),
        items: [
          movement('a', 'Primeira', TransactionType.expense, minor: 12345),
          movement('b', 'Segunda', TransactionType.cardPurchase, minor: 67890),
        ],
      );
      await tester.tap(find.text('Primeira'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(find.text('Segunda'));
      await tester.pump();
      final panel = find.ancestor(
        of: find.text('Detalhes da transação'),
        matching: find.byType(PollarReveal),
      );
      expect(
        find.descendant(of: panel, matching: find.text('Primeira')),
        findsNothing,
      );
      expect(
        find.descendant(of: panel, matching: find.text('Segunda')),
        findsOneWidget,
      );
      final amount = tester.widget<MoneyText>(
        find.descendant(of: panel, matching: find.byType(MoneyText)),
      );
      expect(amount.money.minorUnits.abs(), 67890);
      container.read(privacyModeProvider.notifier).set(true);
      await tester.pump();
      expect(find.byType(MoneyText), findsNothing);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'available width selects modal or panel and excludes filtered details',
    (tester) async {
      await mount(tester, size: const Size(1200, 900));
      await tester.tap(find.text('Despesa comum'));
      await tester.pumpAndSettle();
      expect(find.text('Detalhes da transação'), findsNothing);
      await tester.tap(find.text('Fechar detalhes'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Recolher navegação'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Despesa comum'));
      await tester.pumpAndSettle();
      expect(find.text('Detalhes da transação'), findsOneWidget);
      await tester.enterText(search(), 'Salário');
      await tester.pumpAndSettle();
      expect(find.text('Detalhes da transação'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(TransactionTile),
          matching: find.text('Salário'),
        ),
        findsOneWidget,
      );
    },
  );

  for (final width in [390.0, 1200.0]) {
    testWidgets(
      'open modal reacts immediately to privacy at $width and keeps its footprint',
      (tester) async {
        final handle = tester.ensureSemantics();
        try {
          final container = await mount(
            tester,
            size: Size(width, 900),
            items: [movement('one', 'Mercado', TransactionType.expense)],
          );
          await tester.tap(find.text('Mercado'));
          await tester.pumpAndSettle();
          final amounts = tester
              .widgetList<PrivacyAmount>(find.byType(PrivacyAmount))
              .toList();
          final before = [
            for (final widget in amounts) tester.getRect(find.byWidget(widget)),
          ];
          expect(find.text('Compensado'), findsWidgets);
          container.read(privacyModeProvider.notifier).toggle();
          await tester.pumpAndSettle();
          expect(find.byType(MoneyText), findsNothing);
          expect(find.bySemanticsLabel(RegExp('123,45')), findsNothing);
          final hidden = tester
              .widgetList<PrivacyAmount>(find.byType(PrivacyAmount))
              .toList();
          expect([
            for (final widget in hidden) tester.getRect(find.byWidget(widget)),
          ], before);
          await tester.tap(find.text('Fechar detalhes'));
          await tester.pumpAndSettle();
        } finally {
          handle.dispose();
        }
      },
    );
  }

  testWidgets(
    'long copy and amounts remain complete in narrow double-text details',
    (tester) async {
      const description =
          'Descrição completa muito longa para conferir o histórico sem truncar conteúdo';
      await mount(
        tester,
        size: const Size(320, 900),
        scale: 2,
        items: [
          movement(
            'long',
            description,
            TransactionType.expense,
            minor: 99999999999999,
          ),
        ],
      );
      final row = find.byType(TransactionTile);
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.text(description)).maxLines, isNull);
      final data = tester.widget<TransactionTile>(row);
      expect(data.reflowContent, isTrue);
      await tester.tap(find.text(description));
      await tester.pumpAndSettle();
      for (final amount in tester.widgetList<PrivacyAmount>(
        find.byType(PrivacyAmount),
      )) {
        expect(amount.allowWrap, isTrue);
        expect(amount.reserveLayout, isTrue);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'long filter option remains selectable with 320px and double text',
    (tester) async {
      await mount(tester, size: const Size(320, 900), scale: 2);
      await type(tester, 'transfer', 'Transferências');
      expect(find.text('2 transações'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Pagamento da fatura'),
        300,
        scrollable: scroll(),
      );
      expect(find.text('Pagamento da fatura'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'resizing preserves focused query across control and scrolling layouts',
    (tester) async {
      await mount(tester, size: const Size(1440, 900));
      await tester.enterText(search(), 'Sal');
      final field = find.descendant(
        of: search(),
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(field).focusNode.hasFocus, isTrue);
      final focus = tester.widget<EditableText>(field).focusNode;
      for (final size in const [
        Size(1200, 900),
        Size(700, 900),
        Size(1440, 900),
        Size(1440, 380),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(tester.widget<TextFormField>(search()).controller!.text, 'Sal');
        expect(tester.widget<EditableText>(field).focusNode, same(focus));
        expect(focus.hasFocus, isTrue);
        expect(tester.takeException(), isNull);
      }
      await tester.scrollUntilVisible(
        find.text('Salário'),
        150,
        scrollable: scroll(),
      );
      expect(find.text('Salário'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('privacy keeps row geometry stable in the desktop ledger', (
    tester,
  ) async {
    await mount(tester, size: const Size(1440, 1000));
    List<Rect> amounts() => [
      for (final widget in tester.widgetList<PrivacyAmount>(
        find.byType(PrivacyAmount),
      ))
        tester.getRect(find.byWidget(widget)),
    ];
    final before = amounts();
    await tester.tap(find.byTooltip('Ocultar valores'));
    await tester.pumpAndSettle();
    expect(amounts(), before);
    expect(find.byType(MoneyText), findsNothing);
  });
}

class _Catalog implements TransactionAccountCatalog {
  const _Catalog();
  @override
  Future<List<TransactionAccountReference>> findAll() async => const [
    TransactionAccountReference(
      id: 'checking',
      name: 'Conta principal',
      currency: Currency.brl,
      isCreditCard: false,
      isArchived: false,
    ),
    TransactionAccountReference(
      id: 'savings',
      name: 'Reserva',
      currency: Currency.brl,
      isCreditCard: false,
      isArchived: false,
    ),
    TransactionAccountReference(
      id: 'card',
      name: 'Cartão Ouro',
      currency: Currency.brl,
      isCreditCard: true,
      isArchived: false,
    ),
  ];
}

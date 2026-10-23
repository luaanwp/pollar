import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/transactions/application/transaction_account_catalog.dart';
import 'package:pollar_app/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:pollar_app/features/transactions/domain/financial_transaction.dart';
import 'package:pollar_app/features/transactions/presentation/transactions_controller.dart';
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

  Future<void> renderTransactions(
    WidgetTester tester, {
    required Size size,
    required String golden,
    bool openForm = false,
    bool openDetail = false,
    bool openDiscardConfirmation = false,
    bool dark = false,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final today = DateTime(2026, 9, 8);
    final repository = InMemoryTransactionRepository(
      seed: [
        FinancialTransaction(
          id: 'market',
          description: 'Mercado do bairro',
          type: TransactionType.expense,
          status: TransactionStatus.compensado,
          amount: const Money(minorUnits: 23480, currency: Currency.brl),
          accountId: 'card',
          occurredAt: today,
          category: 'Alimentação',
        ),
        FinancialTransaction(
          id: 'salary',
          description: 'Salário',
          type: TransactionType.income,
          status: TransactionStatus.conciliado,
          amount: const Money(minorUnits: 920000, currency: Currency.brl),
          accountId: 'checking',
          occurredAt: today,
          category: 'Renda',
        ),
        FinancialTransaction(
          id: 'reserve',
          description: 'Reserva mensal',
          type: TransactionType.transfer,
          status: TransactionStatus.pendente,
          amount: const Money(minorUnits: 50000, currency: Currency.brl),
          accountId: 'checking',
          counterAccountId: 'savings',
          occurredAt: today.subtract(const Duration(days: 1)),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(repository),
          transactionAccountCatalogProvider.overrideWithValue(
            const _GoldenAccountCatalog(),
          ),
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
    if (dark) {
      await tester.tap(find.byTooltip('Tema escuro'));
      await tester.pumpAndSettle();
    }
    if (openForm) {
      await tester.tap(find.text('Nova transação'));
      await tester.pumpAndSettle();
    }
    if (openDiscardConfirmation) {
      final description = find.descendant(
        of: find.byKey(const Key('transaction-description')),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(description, 'Rascunho de mercado');
      await tester.tap(find.byTooltip('Voltar para transações'));
      await tester.pumpAndSettle();
    }
    if (openDetail) {
      await tester.tap(find.text('Mercado do bairro'));
      await tester.pumpAndSettle();
    }

    await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
  }

  testWidgets('transactions compact 390x900', (tester) async {
    await renderTransactions(
      tester,
      size: const Size(390, 900),
      golden: 'transactions_390x900.png',
    );
  });

  testWidgets('transactions wide detail 1440x900', (tester) async {
    await renderTransactions(
      tester,
      size: const Size(1440, 900),
      golden: 'transactions_detail_1440x900.png',
      openDetail: true,
    );
  });

  testWidgets('notebook detail uses a bounded dialog', (tester) async {
    await renderTransactions(
      tester,
      size: const Size(1200, 900),
      golden: 'transaction_detail_1200_modal.png',
      openDetail: true,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('transaction form compact 390x900', (tester) async {
    await renderTransactions(
      tester,
      size: const Size(390, 900),
      golden: 'transaction_form_390x900.png',
      openForm: true,
    );
  });

  testWidgets('transaction detail compact 390x900', (tester) async {
    await renderTransactions(
      tester,
      size: const Size(390, 900),
      golden: 'transaction_detail_390x900.png',
      openDetail: true,
    );
  });

  testWidgets('transaction discard confirmation compact 390x900', (
    tester,
  ) async {
    await renderTransactions(
      tester,
      size: const Size(390, 900),
      golden: 'transaction_discard_390x900.png',
      openForm: true,
      openDiscardConfirmation: true,
    );
  });

  for (final sample in [
    (
      size: const Size(320, 844),
      scale: 1.3,
      dark: false,
      name: 'transactions_320_light_130pct.png',
    ),
    (
      size: const Size(390, 900),
      scale: 1.0,
      dark: true,
      name: 'transactions_390_dark.png',
    ),
    (
      size: const Size(390, 900),
      scale: 2.0,
      dark: false,
      name: 'transactions_390_light_2x.png',
    ),
    (
      size: const Size(800, 1000),
      scale: 1.0,
      dark: false,
      name: 'transactions_800_light.png',
    ),
    (
      size: const Size(1440, 900),
      scale: 1.0,
      dark: true,
      name: 'transactions_1440_dark.png',
    ),
    (
      size: const Size(1440, 1000),
      scale: 2.0,
      dark: false,
      name: 'transactions_1440_light_2x.png',
    ),
  ]) {
    testWidgets(sample.name, (tester) async {
      await renderTransactions(
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

class _GoldenAccountCatalog implements TransactionAccountCatalog {
  const _GoldenAccountCatalog();

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

import 'package:flutter/material.dart';
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
  const checking = TransactionAccountReference(
    id: 'checking',
    name: 'Conta principal',
    currency: Currency.brl,
    isCreditCard: false,
    isArchived: false,
  );
  const savings = TransactionAccountReference(
    id: 'savings',
    name: 'Reserva',
    currency: Currency.brl,
    isCreditCard: false,
    isArchived: false,
  );
  const card = TransactionAccountReference(
    id: 'card',
    name: 'Cartão Ouro',
    currency: Currency.brl,
    isCreditCard: true,
    isArchived: false,
  );

  FinancialTransaction transaction(
    String id,
    String description,
    TransactionType type,
    int amount, {
    String accountId = 'checking',
    String? counterAccountId,
  }) => FinancialTransaction(
    id: id,
    description: description,
    type: type,
    status: TransactionStatus.compensado,
    amount: Money(minorUnits: amount, currency: Currency.brl),
    accountId: accountId,
    counterAccountId: counterAccountId,
    occurredAt: DateUtils.dateOnly(DateTime.now()),
    category: type == TransactionType.income ? 'Renda' : 'Alimentação',
  );

  Widget app(InMemoryTransactionRepository repository) => ProviderScope(
    overrides: [
      transactionRepositoryProvider.overrideWithValue(repository),
      transactionAccountCatalogProvider.overrideWithValue(
        const _Catalog([checking, savings, card]),
      ),
    ],
    child: const PollarApp(),
  );

  Future<void> openTransactions(
    WidgetTester tester,
    InMemoryTransactionRepository repository,
  ) async {
    await tester.pumpWidget(app(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transações').first);
    await tester.pumpAndSettle();
  }

  Finder field(String key) => find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(TextFormField),
  );

  testWidgets('lists, filters and masks transaction amounts', (tester) async {
    final repository = InMemoryTransactionRepository(
      seed: [
        transaction('expense', 'Mercado', TransactionType.expense, 23480),
        transaction('income', 'Salário', TransactionType.income, 920000),
      ],
    );
    await openTransactions(tester, repository);

    expect(find.text('Mercado'), findsOneWidget);
    expect(find.text('Salário'), findsOneWidget);
    expect(find.text(r'−R$ 234,80'), findsOneWidget);

    await tester.tap(find.text('Receitas'));
    await tester.pumpAndSettle();
    expect(find.text('Mercado'), findsNothing);
    expect(find.text('Salário'), findsOneWidget);

    await tester.tap(find.byTooltip('Ocultar valores'));
    await tester.pump();
    expect(find.text(r'+R$ 9.200,00'), findsNothing);
    expect(find.textContaining('•••••'), findsWidgets);
  });

  testWidgets('creates a card expense as a card purchase', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = InMemoryTransactionRepository();
    await openTransactions(tester, repository);

    await tester.tap(find.text('Nova transação'));
    await tester.pumpAndSettle();
    await tester.enterText(field('transaction-description'), 'Farmácia');
    await tester.enterText(field('transaction-amount-expense-null'), '89,90');
    await tester.tap(find.byKey(const ValueKey('source-expense')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cartão Ouro').last);
    await tester.pumpAndSettle();
    await tester.enterText(field('transaction-amount-expense-BRL'), '89,90');
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar transação'));
    await tester.pumpAndSettle();

    final saved = (await repository.findAll()).single;
    expect(saved.type, TransactionType.cardPurchase);
    expect(saved.accountId, 'card');
    expect(find.text('Farmácia'), findsOneWidget);
    expect(find.text('Transação salva.'), findsOneWidget);
  });

  testWidgets('opens details and cancels while preserving the record', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = InMemoryTransactionRepository(
      seed: [transaction('expense', 'Mercado', TransactionType.expense, 23480)],
    );
    await openTransactions(tester, repository);

    await tester.tap(find.text('Mercado'));
    await tester.pumpAndSettle();
    expect(find.text('Detalhes da transação'), findsNothing);
    expect(find.text('Cancelar transação'), findsOneWidget);
    await tester.tap(find.text('Cancelar transação'));
    await tester.pumpAndSettle();
    expect(find.text('Cancelar Mercado?'), findsOneWidget);
    await tester.tap(find.text('Cancelar transação'));
    await tester.pumpAndSettle();

    expect((await repository.findById('expense'))?.isCanceled, isTrue);
    expect(find.text('Cancelado'), findsOneWidget);
    expect(find.text('Transação cancelada.'), findsOneWidget);
  });

  testWidgets('warns before discarding a transaction being filled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openTransactions(tester, InMemoryTransactionRepository());
    await tester.tap(find.text('Nova transação'));
    await tester.pumpAndSettle();
    await tester.enterText(field('transaction-description'), 'Rascunho');

    await tester.tap(find.byTooltip('Voltar para transações'));
    await tester.pumpAndSettle();

    expect(find.text('Descartar transação não salva?'), findsOneWidget);
    await tester.tap(find.text('Continuar preenchendo'));
    await tester.pumpAndSettle();
    expect(find.text('Rascunho'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar para transações'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar transação'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma transação ainda'), findsOneWidget);
  });

  testWidgets('wide layout opens the contextual detail panel', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = InMemoryTransactionRepository(
      seed: [transaction('income', 'Salário', TransactionType.income, 920000)],
    );
    await openTransactions(tester, repository);

    await tester.tap(find.text('Salário'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhes da transação'), findsOneWidget);
    expect(find.text('Conta principal'), findsWidgets);
    expect(find.byTooltip('Fechar detalhes'), findsOneWidget);
  });

  testWidgets('compact ledger supports 200% system text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final repository = InMemoryTransactionRepository(
      seed: [transaction('income', 'Salário', TransactionType.income, 920000)],
    );

    await openTransactions(tester, repository);

    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Salário'), findsOneWidget);
  });
}

class _Catalog implements TransactionAccountCatalog {
  const _Catalog(this.accounts);

  final List<TransactionAccountReference> accounts;

  @override
  Future<List<TransactionAccountReference>> findAll() async => accounts;
}

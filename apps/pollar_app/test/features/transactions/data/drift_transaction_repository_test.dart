import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/accounts/data/drift_account_repository.dart';
import 'package:pollar_app/features/accounts/domain/account.dart';
import 'package:pollar_app/features/transactions/data/drift_transaction_repository.dart';
import 'package:pollar_app/features/transactions/domain/financial_transaction.dart';
import 'package:pollar_app/shared/data/local_database.dart';

void main() {
  late LocalDatabase database;
  late DriftTransactionRepository repository;

  setUp(() async {
    database = LocalDatabase(NativeDatabase.memory());
    final accounts = DriftAccountRepository(database);
    for (final id in ['source', 'destination']) {
      await accounts.add(
        Account(
          id: id,
          name: id,
          type: AccountType.checking,
          currency: Currency.brl,
          openingBalance: const Money.zero(Currency.brl),
        ),
      );
    }
    await accounts.add(
      Account(
        id: 'card',
        name: 'Cartão',
        type: AccountType.creditCard,
        currency: Currency.brl,
        openingBalance: const Money.zero(Currency.brl),
        creditCardTerms: CreditCardTerms(
          creditLimit: const Money(minorUnits: 100000, currency: Currency.brl),
          closingDay: 20,
          dueDay: 28,
        ),
      ),
    );
    repository = DriftTransactionRepository(database);
  });

  tearDown(() => database.close());

  FinancialTransaction transaction(
    String id,
    TransactionType type, {
    String accountId = 'source',
    String? counterAccountId,
  }) => FinancialTransaction(
    id: id,
    description: 'Transação $id',
    type: type,
    status: TransactionStatus.pendente,
    amount: const Money(minorUnits: 9876, currency: Currency.brl),
    accountId: accountId,
    counterAccountId: counterAccountId,
    occurredAt: DateTime(2026, 9, 8, 14, 30),
    category: 'Categoria',
    note: 'Observação',
  );

  test('round-trips single and two-legged transaction fields', () async {
    final expense = transaction('expense', TransactionType.expense);
    final transfer = transaction(
      'transfer',
      TransactionType.transfer,
      counterAccountId: 'destination',
    );

    await repository.add(expense);
    await repository.add(transfer);

    expect(await repository.findById(expense.id), expense);
    expect(await repository.findById(transfer.id), transfer);
    expect((await repository.findAll()).toSet(), {expense, transfer});
  });

  test('replace persists cancellation and rejects unknown ids', () async {
    final value = transaction('expense', TransactionType.expense);
    await repository.add(value);

    await repository.replace(value.cancel());

    expect((await repository.findById(value.id))?.isCanceled, isTrue);
    expect(
      repository.replace(transaction('missing', TransactionType.income)),
      throwsStateError,
    );
  });

  test('round-trips installment and statement linkage metadata', () async {
    final installment = FinancialTransaction(
      id: 'part-2',
      description: 'Notebook',
      type: TransactionType.cardPurchase,
      status: TransactionStatus.previsto,
      amount: const Money(minorUnits: 3333, currency: Currency.brl),
      accountId: 'card',
      occurredAt: DateTime(2026, 10, 8),
      installmentGroupId: 'purchase',
      installmentNumber: 2,
      installmentCount: 3,
      purchaseTotal: const Money(minorUnits: 10000, currency: Currency.brl),
    );
    final payment = FinancialTransaction(
      id: 'payment',
      description: 'Pagamento de fatura',
      type: TransactionType.cardStatementPayment,
      status: TransactionStatus.compensado,
      amount: const Money(minorUnits: 5000, currency: Currency.brl),
      accountId: 'source',
      counterAccountId: 'card',
      occurredAt: DateTime(2026, 9, 20),
      statementId: 'card:2026-09-20',
    );
    await repository.addAll([installment, payment]);
    expect(await repository.findById(installment.id), installment);
    expect(await repository.findById(payment.id), payment);
  });

  test('foreign keys reject transactions for unknown accounts', () async {
    expect(
      repository.add(
        transaction('invalid', TransactionType.expense, accountId: 'unknown'),
      ),
      throwsA(anything),
    );
  });
}

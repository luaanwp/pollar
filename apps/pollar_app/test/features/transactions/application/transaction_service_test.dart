import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/transactions/application/transaction_account_catalog.dart';
import 'package:pollar_app/features/transactions/application/transaction_service.dart';
import 'package:pollar_app/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:pollar_app/features/transactions/domain/financial_transaction.dart';

void main() {
  const checking = TransactionAccountReference(
    id: 'checking',
    name: 'Conta',
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
    name: 'Cartão',
    currency: Currency.brl,
    isCreditCard: true,
    isArchived: false,
  );
  final date = DateTime(2026, 9, 8);

  FinancialTransaction transaction({
    String id = 'tx',
    TransactionType type = TransactionType.expense,
    String accountId = 'checking',
    String? counterAccountId,
  }) => FinancialTransaction(
    id: id,
    description: 'Lançamento',
    type: type,
    status: TransactionStatus.compensado,
    amount: const Money(minorUnits: 5000, currency: Currency.brl),
    accountId: accountId,
    counterAccountId: counterAccountId,
    occurredAt: date,
  );

  test('creates valid entries and cancels without deleting them', () async {
    final repository = InMemoryTransactionRepository();
    final service = TransactionService(
      repository,
      const _Catalog([checking, savings, card]),
    );

    await service.create(transaction());
    final canceled = await service.cancel('tx');

    expect(canceled.status, TransactionStatus.cancelado);
    expect(await service.list(), [canceled]);
  });

  test(
    'creates an exact monthly installment plan and clamps month ends',
    () async {
      final repository = InMemoryTransactionRepository();
      final service = TransactionService(
        repository,
        const _Catalog([checking, savings, card]),
      );
      final purchase = FinancialTransaction(
        id: 'draft',
        description: 'Notebook',
        type: TransactionType.cardPurchase,
        status: TransactionStatus.compensado,
        amount: const Money(minorUnits: 10001, currency: Currency.brl),
        accountId: 'card',
        occurredAt: DateTime(2026, 1, 31),
      );

      final result = await service.createInstallmentPlan(
        purchase: purchase,
        installmentCount: 3,
        groupId: 'group',
        idForInstallment: (number) => 'part-$number',
      );

      expect(result.map((item) => item.amount.minorUnits), [3334, 3334, 3333]);
      expect(result.map((item) => item.occurredAt), [
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 31),
      ]);
      expect(result.map((item) => item.status), [
        TransactionStatus.compensado,
        TransactionStatus.previsto,
        TransactionStatus.previsto,
      ]);
      expect(result.last.purchaseTotal, purchase.amount);
      expect(result.last.installmentNumber, 3);
    },
  );

  test('validates transfer and credit-card account roles', () async {
    final service = TransactionService(
      InMemoryTransactionRepository(),
      const _Catalog([checking, savings, card]),
    );

    await service.create(
      transaction(
        id: 'transfer',
        type: TransactionType.transfer,
        counterAccountId: 'savings',
      ),
    );
    await service.create(
      transaction(
        id: 'card-purchase',
        type: TransactionType.cardPurchase,
        accountId: 'card',
      ),
    );

    expect(
      service.create(
        transaction(id: 'wrong-card', type: TransactionType.cardPurchase),
      ),
      throwsA(isA<TransactionAccountMismatchException>()),
    );
    expect(
      service.create(
        transaction(
          id: 'wrong-transfer',
          type: TransactionType.transfer,
          counterAccountId: 'card',
        ),
      ),
      throwsA(isA<TransactionAccountMismatchException>()),
    );
  });

  test('rejects missing, archived and duplicate identities', () async {
    const archived = TransactionAccountReference(
      id: 'archived',
      name: 'Antiga',
      currency: Currency.brl,
      isCreditCard: false,
      isArchived: true,
    );
    final repository = InMemoryTransactionRepository();
    final service = TransactionService(
      repository,
      const _Catalog([checking, archived]),
    );
    await service.create(transaction());

    expect(
      service.create(transaction()),
      throwsA(isA<TransactionAlreadyExistsException>()),
    );
    expect(
      service.create(transaction(id: 'missing', accountId: 'unknown')),
      throwsA(isA<TransactionAccountUnavailableException>()),
    );
    expect(
      service.create(transaction(id: 'archived-tx', accountId: 'archived')),
      throwsA(isA<TransactionAccountUnavailableException>()),
    );
    expect(
      service.cancel('unknown'),
      throwsA(isA<TransactionNotFoundException>()),
    );
  });
}

class _Catalog implements TransactionAccountCatalog {
  const _Catalog(this.accounts);

  final List<TransactionAccountReference> accounts;

  @override
  Future<List<TransactionAccountReference>> findAll() async => accounts;
}

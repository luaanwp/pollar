import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/ledger/posting.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/transactions/domain/financial_transaction.dart';

void main() {
  const amount = Money(minorUnits: 12550, currency: Currency.brl);
  final date = DateTime(2026, 9, 8);

  FinancialTransaction transaction({
    TransactionType type = TransactionType.expense,
    String? counterAccountId,
  }) => FinancialTransaction(
    id: ' tx-1 ',
    description: ' Mercado ',
    type: type,
    status: TransactionStatus.compensado,
    amount: amount,
    accountId: ' source ',
    counterAccountId: counterAccountId,
    occurredAt: date,
    category: ' Alimentação ',
    note: ' ',
  );

  test(
    'normalizes text and derives signed postings from the central rules',
    () {
      final value = transaction();

      expect(value.id, 'tx-1');
      expect(value.description, 'Mercado');
      expect(value.accountId, 'source');
      expect(value.category, 'Alimentação');
      expect(value.note, isNull);
      expect(value.postings.single.signedAmount, -amount);
    },
  );

  test('transfer requires a distinct counter account and creates two legs', () {
    expect(
      () => transaction(type: TransactionType.transfer),
      throwsA(isA<MissingCounterAccountError>()),
    );

    final value = transaction(
      type: TransactionType.transfer,
      counterAccountId: 'destination',
    );
    expect(value.postings.map((posting) => posting.signedAmount), [
      -amount,
      amount,
    ]);
  });

  test(
    'rejects non-positive magnitudes and cancellation preserves history',
    () {
      expect(
        () => FinancialTransaction(
          id: 'zero',
          description: 'Zero',
          type: TransactionType.income,
          status: TransactionStatus.previsto,
          amount: const Money.zero(Currency.brl),
          accountId: 'source',
          occurredAt: date,
        ),
        throwsA(isA<NonPositiveAmountError>()),
      );

      final canceled = transaction().cancel();
      expect(canceled.status, TransactionStatus.cancelado);
      expect(canceled.description, 'Mercado');
      expect(canceled.postings.single.status, TransactionStatus.cancelado);
    },
  );
}

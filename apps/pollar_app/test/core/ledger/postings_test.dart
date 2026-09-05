import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/ledger/posting.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';

void main() {
  const brl = Currency.brl;
  const amount = Money(minorUnits: 10000, currency: brl); // R$ 100,00
  const status = TransactionStatus.compensado;

  Money signedFor(List<Posting> ps, String account) => ps
      .where((p) => p.accountId == account)
      .fold(Money.zero(brl), (acc, p) => acc + p.signedAmount);

  test('income posts a single positive entry to the account', () {
    final ps = postingsFor(
      type: TransactionType.income,
      status: status,
      amount: amount,
      accountId: 'acc',
    );
    expect(ps, hasLength(1));
    expect(signedFor(ps, 'acc'), amount);
    expect(ps.single.status, status);
  });

  test('expense posts a single negative entry to the account', () {
    final ps = postingsFor(
      type: TransactionType.expense,
      status: status,
      amount: amount,
      accountId: 'acc',
    );
    expect(ps, hasLength(1));
    expect(signedFor(ps, 'acc'), -amount);
  });

  test('transfer moves both accounts and nets to zero', () {
    final ps = postingsFor(
      type: TransactionType.transfer,
      status: status,
      amount: amount,
      accountId: 'from',
      counterAccountId: 'to',
    );
    expect(ps, hasLength(2));
    expect(signedFor(ps, 'from'), -amount);
    expect(signedFor(ps, 'to'), amount);
  });

  test(
    'card purchase moves only the card account (debt), not a bank account',
    () {
      final ps = postingsFor(
        type: TransactionType.cardPurchase,
        status: status,
        amount: amount,
        accountId: 'card',
      );
      expect(ps, hasLength(1));
      expect(signedFor(ps, 'card'), -amount);
    },
  );

  test('card statement payment reduces bank and reduces card debt', () {
    final ps = postingsFor(
      type: TransactionType.cardStatementPayment,
      status: status,
      amount: amount,
      accountId: 'bank',
      counterAccountId: 'card',
    );
    expect(ps, hasLength(2));
    expect(signedFor(ps, 'bank'), -amount); // bank goes down
    expect(signedFor(ps, 'card'), amount); // card debt goes up toward zero
  });

  group('invariants', () {
    test('amount must be a positive magnitude', () {
      expect(
        () => postingsFor(
          type: TransactionType.expense,
          status: status,
          amount: const Money(minorUnits: -1, currency: brl),
          accountId: 'acc',
        ),
        throwsA(isA<NonPositiveAmountError>()),
      );
      expect(
        () => postingsFor(
          type: TransactionType.expense,
          status: status,
          amount: Money.zero(brl),
          accountId: 'acc',
        ),
        throwsA(isA<NonPositiveAmountError>()),
      );
    });

    test('two-legged types require a distinct counter account', () {
      expect(
        () => postingsFor(
          type: TransactionType.transfer,
          status: status,
          amount: amount,
          accountId: 'from',
        ),
        throwsA(isA<MissingCounterAccountError>()),
      );
      expect(
        () => postingsFor(
          type: TransactionType.transfer,
          status: status,
          amount: amount,
          accountId: 'same',
          counterAccountId: 'same',
        ),
        throwsA(isA<MissingCounterAccountError>()),
      );
    });

    test('single-legged types reject a counter account', () {
      expect(
        () => postingsFor(
          type: TransactionType.expense,
          status: status,
          amount: amount,
          accountId: 'acc',
          counterAccountId: 'other',
        ),
        throwsA(isA<UnexpectedCounterAccountError>()),
      );
    });
  });
}

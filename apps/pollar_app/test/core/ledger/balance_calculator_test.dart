import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/ledger/balance_calculator.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/ledger/posting.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';

void main() {
  const brl = Currency.brl;
  Money brlOf(int minor) => Money(minorUnits: minor, currency: brl);
  final opening = brlOf(100000); // R$ 1.000,00

  AccountBalance balanceOf(
    String accountId,
    List<Posting> postings, {
    Money? open,
  }) => computeAccountBalance(
    accountId: accountId,
    openingBalance: open ?? opening,
    postings: postings,
  );

  List<Posting> expense(TransactionStatus status) => postingsFor(
    type: TransactionType.expense,
    status: status,
    amount: brlOf(30000), // R$ 300,00
    accountId: 'acc',
  );

  group('expense by status', () {
    test('previsto affects projected only', () {
      final b = balanceOf('acc', expense(TransactionStatus.previsto));
      expect(b.confirmed, opening);
      expect(b.projected, brlOf(70000));
    });

    test('pendente affects projected only', () {
      final b = balanceOf('acc', expense(TransactionStatus.pendente));
      expect(b.confirmed, opening);
      expect(b.projected, brlOf(70000));
    });

    test('compensado affects confirmed and projected', () {
      final b = balanceOf('acc', expense(TransactionStatus.compensado));
      expect(b.confirmed, brlOf(70000));
      expect(b.projected, brlOf(70000));
    });

    test('conciliado affects confirmed and projected', () {
      final b = balanceOf('acc', expense(TransactionStatus.conciliado));
      expect(b.confirmed, brlOf(70000));
      expect(b.projected, brlOf(70000));
    });

    test('cancelado affects neither', () {
      final b = balanceOf('acc', expense(TransactionStatus.cancelado));
      expect(b.confirmed, opening);
      expect(b.projected, opening);
    });
  });

  test('income compensado increases both balances', () {
    final b = balanceOf(
      'acc',
      postingsFor(
        type: TransactionType.income,
        status: TransactionStatus.compensado,
        amount: brlOf(50000),
        accountId: 'acc',
      ),
    );
    expect(b.confirmed, brlOf(150000));
    expect(b.projected, brlOf(150000));
  });

  test('transfer compensado moves both accounts', () {
    final ps = postingsFor(
      type: TransactionType.transfer,
      status: TransactionStatus.compensado,
      amount: brlOf(20000),
      accountId: 'from',
      counterAccountId: 'to',
    );
    expect(balanceOf('from', ps).confirmed, brlOf(80000));
    expect(balanceOf('to', ps).confirmed, brlOf(120000));
  });

  test('card purchase increases card debt but leaves bank untouched', () {
    final ps = postingsFor(
      type: TransactionType.cardPurchase,
      status: TransactionStatus.compensado,
      amount: brlOf(15000),
      accountId: 'card',
    );
    // Card account starts at zero debt.
    expect(
      balanceOf('card', ps, open: Money.zero(brl)).confirmed,
      brlOf(-15000),
    );
    // A bank account with no postings here is unaffected.
    expect(balanceOf('bank', ps).confirmed, opening);
  });

  test(
    'statement payment reduces bank and reduces card debt, not an expense',
    () {
      final ps = postingsFor(
        type: TransactionType.cardStatementPayment,
        status: TransactionStatus.compensado,
        amount: brlOf(15000),
        accountId: 'bank',
        counterAccountId: 'card',
      );
      expect(balanceOf('bank', ps).confirmed, brlOf(85000));
      // Card debt of -15000 is paid back to 0.
      expect(
        balanceOf('card', ps, open: brlOf(-15000)).confirmed,
        Money.zero(brl),
      );
    },
  );

  test('mixed statuses accumulate correctly', () {
    final postings = <Posting>[
      ...expense(TransactionStatus.compensado), // -300 confirmed+projected
      ...expense(TransactionStatus.previsto), // -300 projected only
      ...postingsFor(
        type: TransactionType.income,
        status: TransactionStatus.conciliado,
        amount: brlOf(10000), // +100 both
        accountId: 'acc',
      ),
      ...expense(TransactionStatus.cancelado), // ignored
    ];
    final b = balanceOf('acc', postings);
    expect(b.confirmed, brlOf(80000)); // 1000 - 300 + 100
    expect(b.projected, brlOf(50000)); // 800 - 300
  });
}

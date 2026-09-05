import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';

void main() {
  group('TransactionStatus balance effect', () {
    test('previsto affects only projected balance', () {
      expect(TransactionStatus.previsto.affectsConfirmed, isFalse);
      expect(TransactionStatus.previsto.affectsProjected, isTrue);
    });

    test('pendente affects only projected balance', () {
      expect(TransactionStatus.pendente.affectsConfirmed, isFalse);
      expect(TransactionStatus.pendente.affectsProjected, isTrue);
    });

    test('compensado affects confirmed and projected', () {
      expect(TransactionStatus.compensado.affectsConfirmed, isTrue);
      expect(TransactionStatus.compensado.affectsProjected, isTrue);
    });

    test('conciliado affects confirmed and projected', () {
      expect(TransactionStatus.conciliado.affectsConfirmed, isTrue);
      expect(TransactionStatus.conciliado.affectsProjected, isTrue);
    });

    test('cancelado affects no balance', () {
      expect(TransactionStatus.cancelado.affectsConfirmed, isFalse);
      expect(TransactionStatus.cancelado.affectsProjected, isFalse);
    });
  });

  group('TransactionType report classification', () {
    test('income and expense count as income/expense for reports', () {
      expect(TransactionType.income.countsAsIncomeOrExpense, isTrue);
      expect(TransactionType.expense.countsAsIncomeOrExpense, isTrue);
    });

    test('card purchase counts as expense for reports', () {
      expect(TransactionType.cardPurchase.countsAsIncomeOrExpense, isTrue);
    });

    test('transfer never counts as income/expense', () {
      expect(TransactionType.transfer.countsAsIncomeOrExpense, isFalse);
    });

    test('card statement payment never counts as income/expense', () {
      expect(
        TransactionType.cardStatementPayment.countsAsIncomeOrExpense,
        isFalse,
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/statements/application/statement_data_source.dart';
import 'package:pollar_app/features/statements/application/statement_service.dart';
import 'package:pollar_app/features/statements/domain/card_statement.dart';

void main() {
  Money brl(int value) => Money(minorUnits: value, currency: Currency.brl);

  test(
    'derives cycle, partial payment, future installments and available limit',
    () async {
      final source = _Source(
        StatementSourceData(
          accounts: [
            StatementAccountRecord(
              id: 'card',
              name: 'Cartão Ouro',
              currency: Currency.brl,
              openingBalance: brl(0),
              isCreditCard: true,
              isArchived: false,
              creditLimit: brl(500000),
              closingDay: 20,
              dueDay: 28,
            ),
            StatementAccountRecord(
              id: 'bank',
              name: 'Conta principal',
              currency: Currency.brl,
              openingBalance: brl(100000),
              isCreditCard: false,
              isArchived: false,
            ),
          ],
          transactions: [
            StatementTransactionRecord(
              id: 'p1',
              description: 'Notebook',
              type: TransactionType.cardPurchase,
              status: TransactionStatus.compensado,
              amount: brl(10000),
              accountId: 'card',
              occurredAt: DateTime(2026, 9, 10),
              category: 'Trabalho',
              installmentNumber: 1,
              installmentCount: 3,
              purchaseTotal: brl(30000),
            ),
            StatementTransactionRecord(
              id: 'p2',
              description: 'Notebook',
              type: TransactionType.cardPurchase,
              status: TransactionStatus.previsto,
              amount: brl(10000),
              accountId: 'card',
              occurredAt: DateTime(2026, 10, 10),
              installmentNumber: 2,
              installmentCount: 3,
              purchaseTotal: brl(30000),
            ),
            StatementTransactionRecord(
              id: 'pay',
              description: 'Pagamento',
              type: TransactionType.cardStatementPayment,
              status: TransactionStatus.compensado,
              amount: brl(4000),
              accountId: 'bank',
              counterAccountId: 'card',
              occurredAt: DateTime(2026, 9, 18),
              statementId: 'card:2026-09-20',
            ),
          ],
        ),
      );
      final snapshot = await StatementService(source)
          .load('card', DateTime(2026, 9, 18));

      expect(snapshot.statement.id, 'card:2026-09-20');
      expect(snapshot.statement.periodStart, DateTime(2026, 8, 21));
      expect(snapshot.statement.dueDate, DateTime(2026, 9, 28));
      expect(snapshot.statement.total, brl(10000));
      expect(snapshot.statement.paid, brl(4000));
      expect(snapshot.statement.outstanding, brl(6000));
      expect(snapshot.statement.status, CardStatementStatus.partiallyPaid);
      expect(snapshot.futureInstallments.single.number, 2);
      expect(snapshot.availableLimit, brl(484000));
    },
  );

  test('clamps closing and due dates in short leap-year months', () async {
    final source = _Source(
      StatementSourceData(
        accounts: [
          StatementAccountRecord(
            id: 'card',
            name: 'Cartão',
            currency: Currency.brl,
            openingBalance: brl(0),
            isCreditCard: true,
            isArchived: false,
            creditLimit: brl(100000),
            closingDay: 31,
            dueDay: 31,
          ),
        ],
        transactions: const [],
      ),
    );
    final snapshot = await StatementService(source)
        .load('card', DateTime(2028, 2, 20));
    expect(snapshot.statement.closingDate, DateTime(2028, 2, 29));
    expect(snapshot.statement.dueDate, DateTime(2028, 3, 31));
  });

  test(
    'keeps the latest unpaid closed cycle visible after its due date',
    () async {
      final source = _Source(
        StatementSourceData(
          accounts: [
            StatementAccountRecord(
              id: 'card',
              name: 'Cartão',
              currency: Currency.brl,
              openingBalance: brl(0),
              isCreditCard: true,
              isArchived: false,
              creditLimit: brl(100000),
              closingDay: 20,
              dueDay: 28,
            ),
          ],
          transactions: [
            StatementTransactionRecord(
              id: 'purchase',
              description: 'Compra',
              type: TransactionType.cardPurchase,
              status: TransactionStatus.compensado,
              amount: brl(1000),
              accountId: 'card',
              occurredAt: DateTime(2026, 9, 10),
            ),
          ],
        ),
      );
      final snapshot = await StatementService(source)
          .load('card', DateTime(2026, 10, 1));
      expect(snapshot.statement.id, 'card:2026-09-20');
      expect(snapshot.statement.status, CardStatementStatus.overdue);
    },
  );

  test('rejects overpayment before writing', () async {
    final source = _Source(
      StatementSourceData(
        accounts: [
          StatementAccountRecord(
            id: 'card',
            name: 'Cartão',
            currency: Currency.brl,
            openingBalance: brl(0),
            isCreditCard: true,
            isArchived: false,
            creditLimit: brl(100000),
            closingDay: 20,
            dueDay: 28,
          ),
          StatementAccountRecord(
            id: 'bank',
            name: 'Conta',
            currency: Currency.brl,
            openingBalance: brl(0),
            isCreditCard: false,
            isArchived: false,
          ),
        ],
        transactions: [
          StatementTransactionRecord(
            id: 'p',
            description: 'Compra',
            type: TransactionType.cardPurchase,
            status: TransactionStatus.compensado,
            amount: brl(1000),
            accountId: 'card',
            occurredAt: DateTime(2026, 9, 1),
          ),
        ],
      ),
    );
    final service = StatementService(source);
    final snapshot = await service.load('card', DateTime(2026, 9, 8));
    expect(
      service.pay(
        snapshot: snapshot,
        command: StatementPaymentCommand(
          id: 'pay',
          statementId: snapshot.statement.id,
          cardId: 'card',
          sourceAccountId: 'bank',
          amount: brl(1001),
          occurredAt: DateTime(2026, 9, 8),
        ),
      ),
      throwsA(isA<InvalidStatementPaymentException>()),
    );
    expect(source.payments, isEmpty);
  });
}

class _Source implements StatementDataSource {
  _Source(this.data);
  final StatementSourceData data;
  final List<StatementPaymentCommand> payments = [];
  @override
  Future<StatementSourceData> load() async => data;
  @override
  Future<void> recordPayment(StatementPaymentCommand command) async =>
      payments.add(command);
}

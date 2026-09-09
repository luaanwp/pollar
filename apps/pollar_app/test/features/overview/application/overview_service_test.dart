import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/overview/application/overview_data_source.dart';
import 'package:pollar_app/features/overview/application/overview_service.dart';

void main() {
  const brl = Currency.brl;
  Money money(int minorUnits) => Money(minorUnits: minorUnits, currency: brl);

  test(
    'derives active cash, card debt and monthly result from postings',
    () async {
      final source = _FakeOverviewDataSource(
        OverviewSourceData(
          accounts: [
            OverviewAccountRecord(
              id: 'checking',
              name: 'Conta principal',
              currency: brl,
              openingBalance: money(100000),
              kind: OverviewAccountKind.asset,
              isArchived: false,
            ),
            OverviewAccountRecord(
              id: 'savings',
              name: 'Reserva',
              currency: brl,
              openingBalance: money(50000),
              kind: OverviewAccountKind.asset,
              isArchived: false,
            ),
            OverviewAccountRecord(
              id: 'card',
              name: 'Cartão Ouro',
              currency: brl,
              openingBalance: money(-20000),
              kind: OverviewAccountKind.creditCard,
              isArchived: false,
            ),
            OverviewAccountRecord(
              id: 'archived',
              name: 'Conta antiga',
              currency: brl,
              openingBalance: money(999999),
              kind: OverviewAccountKind.asset,
              isArchived: true,
            ),
          ],
          transactions: [
            _transaction(
              id: 'income',
              type: TransactionType.income,
              status: TransactionStatus.compensado,
              amount: money(20000),
              accountId: 'checking',
              date: DateTime(2026, 9, 1),
            ),
            _transaction(
              id: 'pending-expense',
              type: TransactionType.expense,
              status: TransactionStatus.pendente,
              amount: money(5000),
              accountId: 'checking',
              date: DateTime(2026, 9, 2),
            ),
            _transaction(
              id: 'transfer',
              type: TransactionType.transfer,
              status: TransactionStatus.compensado,
              amount: money(10000),
              accountId: 'checking',
              counterAccountId: 'savings',
              date: DateTime(2026, 9, 3),
            ),
            _transaction(
              id: 'card-purchase',
              type: TransactionType.cardPurchase,
              status: TransactionStatus.previsto,
              amount: money(3000),
              accountId: 'card',
              date: DateTime(2026, 9, 4),
            ),
            _transaction(
              id: 'canceled',
              type: TransactionType.expense,
              status: TransactionStatus.cancelado,
              amount: money(999),
              accountId: 'checking',
              date: DateTime(2026, 9, 5),
            ),
            _transaction(
              id: 'old-income',
              type: TransactionType.income,
              status: TransactionStatus.compensado,
              amount: money(1000),
              accountId: 'checking',
              date: DateTime(2026, 8, 31),
            ),
          ],
        ),
      );

      final snapshot = await OverviewService(source)
          .load(now: DateTime(2026, 9, 8));
      final summary = snapshot.summaryFor(brl)!;

      expect(summary.confirmed, money(171000));
      expect(summary.projected, money(166000));
      expect(summary.projectedMonthlyIncome, money(20000));
      expect(summary.projectedMonthlyExpenses, money(8000));
      expect(summary.projectedMonthlyResult, money(12000));
      expect(summary.confirmedCardDebt, money(20000));
      expect(summary.projectedCardDebt, money(23000));
      expect(snapshot.accounts.map((item) => item.id), [
        'checking',
        'savings',
        'card',
      ]);
      expect(snapshot.recentTransactions.first.id, 'canceled');
      expect(snapshot.recentTransactions, hasLength(5));
    },
  );

  test('keeps currency summaries separate', () async {
    const usd = Currency.usd;
    final source = _FakeOverviewDataSource(
      OverviewSourceData(
        accounts: [
          OverviewAccountRecord(
            id: 'brl',
            name: 'Real',
            currency: brl,
            openingBalance: money(10000),
            kind: OverviewAccountKind.asset,
            isArchived: false,
          ),
          const OverviewAccountRecord(
            id: 'usd',
            name: 'Dólar',
            currency: usd,
            openingBalance: Money(minorUnits: 2000, currency: usd),
            kind: OverviewAccountKind.asset,
            isArchived: false,
          ),
        ],
        transactions: const [],
      ),
    );

    final snapshot = await OverviewService(source)
        .load(now: DateTime(2026, 9, 8));

    expect(snapshot.summaries, hasLength(2));
    expect(snapshot.summaryFor(brl)!.confirmed, money(10000));
    expect(
      snapshot.summaryFor(usd)!.confirmed,
      const Money(minorUnits: 2000, currency: usd),
    );
  });
}

OverviewTransactionRecord _transaction({
  required String id,
  required TransactionType type,
  required TransactionStatus status,
  required Money amount,
  required String accountId,
  required DateTime date,
  String? counterAccountId,
}) => OverviewTransactionRecord(
  id: id,
  description: id,
  type: type,
  status: status,
  amount: amount,
  accountId: accountId,
  counterAccountId: counterAccountId,
  occurredAt: date,
);

class _FakeOverviewDataSource implements OverviewDataSource {
  const _FakeOverviewDataSource(this.data);

  final OverviewSourceData data;

  @override
  Future<OverviewSourceData> load() async => data;
}

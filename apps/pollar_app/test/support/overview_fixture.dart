import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/overview/application/overview_data_source.dart';

final overviewFixtureNow = DateTime(2026, 9, 8);

class OverviewFixtureDataSource implements OverviewDataSource {
  const OverviewFixtureDataSource();

  static Money _brl(int minorUnits) =>
      Money(minorUnits: minorUnits, currency: Currency.brl);

  @override
  Future<OverviewSourceData> load() async => OverviewSourceData(
    accounts: [
      OverviewAccountRecord(
        id: 'checking',
        name: 'Conta principal',
        currency: Currency.brl,
        openingBalance: _brl(185000),
        kind: OverviewAccountKind.asset,
        isArchived: false,
      ),
      OverviewAccountRecord(
        id: 'wallet',
        name: 'Carteira',
        currency: Currency.brl,
        openingBalance: _brl(18000),
        kind: OverviewAccountKind.asset,
        isArchived: false,
      ),
      OverviewAccountRecord(
        id: 'card',
        name: 'Cartão Ouro',
        currency: Currency.brl,
        openingBalance: _brl(0),
        kind: OverviewAccountKind.creditCard,
        isArchived: false,
      ),
    ],
    transactions: [
      OverviewTransactionRecord(
        id: 'salary',
        description: 'Salário',
        type: TransactionType.income,
        status: TransactionStatus.compensado,
        amount: _brl(920000),
        accountId: 'checking',
        occurredAt: DateTime(2026, 9, 1),
        category: 'Renda',
      ),
      OverviewTransactionRecord(
        id: 'rent',
        description: 'Aluguel',
        type: TransactionType.expense,
        status: TransactionStatus.compensado,
        amount: _brl(320000),
        accountId: 'checking',
        occurredAt: DateTime(2026, 9, 2),
        category: 'Moradia',
      ),
      OverviewTransactionRecord(
        id: 'market',
        description: 'Mercado do bairro',
        type: TransactionType.cardPurchase,
        status: TransactionStatus.pendente,
        amount: _brl(23480),
        accountId: 'card',
        occurredAt: DateTime(2026, 9, 4),
        category: 'Alimentação',
      ),
      OverviewTransactionRecord(
        id: 'streaming',
        description: 'Assinatura streaming',
        type: TransactionType.cardPurchase,
        status: TransactionStatus.previsto,
        amount: _brl(4990),
        accountId: 'card',
        occurredAt: DateTime(2026, 9, 5),
        category: 'Lazer',
      ),
      OverviewTransactionRecord(
        id: 'freelance',
        description: 'Freelance — projeto Vega',
        type: TransactionType.income,
        status: TransactionStatus.previsto,
        amount: _brl(132000),
        accountId: 'checking',
        occurredAt: DateTime(2026, 9, 7),
        category: 'Renda',
      ),
    ],
  );
}

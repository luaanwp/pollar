import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/statements/application/statement_data_source.dart';

final statementFixtureNow = DateTime(2026, 9, 8);

class StatementFixtureDataSource implements StatementDataSource {
  StatementFixtureDataSource();
  final payments = <StatementPaymentCommand>[];
  Money _brl(int value) => Money(minorUnits: value, currency: Currency.brl);

  @override
  Future<StatementSourceData> load() async => StatementSourceData(
    accounts: [
      StatementAccountRecord(
        id: 'card',
        name: 'Cartão Ouro',
        currency: Currency.brl,
        openingBalance: _brl(0),
        isCreditCard: true,
        isArchived: false,
        creditLimit: _brl(500000),
        closingDay: 20,
        dueDay: 28,
      ),
      StatementAccountRecord(
        id: 'bank',
        name: 'Conta principal',
        currency: Currency.brl,
        openingBalance: _brl(850000),
        isCreditCard: false,
        isArchived: false,
      ),
    ],
    transactions: [
      StatementTransactionRecord(
        id: 'market',
        description: 'Mercado do bairro',
        type: TransactionType.cardPurchase,
        status: TransactionStatus.pendente,
        amount: _brl(23480),
        accountId: 'card',
        occurredAt: DateTime(2026, 9, 4),
        category: 'Alimentação',
      ),
      StatementTransactionRecord(
        id: 'notebook-1',
        description: 'Notebook Pro',
        type: TransactionType.cardPurchase,
        status: TransactionStatus.compensado,
        amount: _brl(32083),
        accountId: 'card',
        occurredAt: DateTime(2026, 9, 5),
        category: 'Trabalho',
        installmentNumber: 1,
        installmentCount: 3,
        purchaseTotal: _brl(96249),
      ),
      StatementTransactionRecord(
        id: 'notebook-2',
        description: 'Notebook Pro',
        type: TransactionType.cardPurchase,
        status: TransactionStatus.previsto,
        amount: _brl(32083),
        accountId: 'card',
        occurredAt: DateTime(2026, 10, 5),
        category: 'Trabalho',
        installmentNumber: 2,
        installmentCount: 3,
        purchaseTotal: _brl(96249),
      ),
      StatementTransactionRecord(
        id: 'notebook-3',
        description: 'Notebook Pro',
        type: TransactionType.cardPurchase,
        status: TransactionStatus.previsto,
        amount: _brl(32083),
        accountId: 'card',
        occurredAt: DateTime(2026, 11, 5),
        category: 'Trabalho',
        installmentNumber: 3,
        installmentCount: 3,
        purchaseTotal: _brl(96249),
      ),
    ],
  );

  @override
  Future<void> recordPayment(StatementPaymentCommand command) async =>
      payments.add(command);
}

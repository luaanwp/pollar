import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/reports/application/report_data_source.dart';

final reportFixtureNow = DateTime(2026, 9, 18);

Money _brl(int minor) => Money(minorUnits: minor, currency: Currency.brl);
Money _usd(int minor) => Money(minorUnits: minor, currency: Currency.usd);

class ReportFixtureDataSource implements ReportDataSource {
  const ReportFixtureDataSource();

  @override
  Future<ReportSourceData> load() async => ReportSourceData(
    accounts: [
      ReportAccountRecord(
        id: 'checking',
        currency: Currency.brl,
        openingBalance: _brl(500000),
        isArchived: false,
      ),
      ReportAccountRecord(
        id: 'savings',
        currency: Currency.brl,
        openingBalance: _brl(100000),
        isArchived: false,
      ),
      ReportAccountRecord(
        id: 'card',
        currency: Currency.brl,
        openingBalance: _brl(0),
        isArchived: false,
      ),
      ReportAccountRecord(
        id: 'usd',
        currency: Currency.usd,
        openingBalance: _usd(10000),
        isArchived: false,
      ),
    ],
    transactions: [
      _transaction(
        id: 'apr-income',
        description: 'Salário abril',
        type: TransactionType.income,
        amount: _brl(400000),
        occurredAt: DateTime(2026, 4, 1),
        category: 'Renda',
      ),
      _transaction(
        id: 'apr-rent',
        description: 'Aluguel abril',
        type: TransactionType.expense,
        amount: _brl(150000),
        occurredAt: DateTime(2026, 4, 5),
        category: 'Moradia',
      ),
      _transaction(
        id: 'may-income',
        description: 'Salário maio',
        type: TransactionType.income,
        amount: _brl(500000),
        occurredAt: DateTime(2026, 5, 1),
        category: 'Renda',
      ),
      _transaction(
        id: 'may-market',
        description: 'Mercado',
        type: TransactionType.cardPurchase,
        amount: _brl(180000),
        accountId: 'card',
        occurredAt: DateTime(2026, 5, 8),
        category: 'Alimentação',
      ),
      _transaction(
        id: 'jun-income',
        description: 'Salário junho',
        type: TransactionType.income,
        amount: _brl(450000),
        occurredAt: DateTime(2026, 6, 1),
        category: 'Renda',
      ),
      _transaction(
        id: 'jun-health',
        description: 'Consulta',
        type: TransactionType.expense,
        amount: _brl(170000),
        occurredAt: DateTime(2026, 6, 10),
        category: 'Saúde',
      ),
      _transaction(
        id: 'jul-income',
        description: 'Salário julho',
        type: TransactionType.income,
        amount: _brl(520000),
        occurredAt: DateTime(2026, 7, 1),
        category: 'Renda',
      ),
      _transaction(
        id: 'jul-rent',
        description: 'Aluguel julho',
        type: TransactionType.expense,
        amount: _brl(200000),
        occurredAt: DateTime(2026, 7, 5),
        category: 'Moradia',
      ),
      _transaction(
        id: 'aug-income',
        description: 'Salário agosto',
        type: TransactionType.income,
        amount: _brl(480000),
        occurredAt: DateTime(2026, 8, 1),
        category: 'Renda',
      ),
      _transaction(
        id: 'aug-market',
        description: 'Feira',
        type: TransactionType.expense,
        amount: _brl(210000),
        occurredAt: DateTime(2026, 8, 9),
        category: 'Alimentação',
      ),
      _transaction(
        id: 'sep-income',
        description: 'Salário setembro',
        type: TransactionType.income,
        amount: _brl(550000),
        occurredAt: DateTime(2026, 9, 1),
        category: 'Renda',
      ),
      _transaction(
        id: 'sep-rent',
        description: 'Aluguel setembro',
        type: TransactionType.expense,
        amount: _brl(200000),
        occurredAt: DateTime(2026, 9, 5),
        category: 'Moradia',
      ),
      _transaction(
        id: 'sep-leisure',
        description: 'Cinema',
        type: TransactionType.cardPurchase,
        amount: _brl(50000),
        accountId: 'card',
        occurredAt: DateTime(2026, 9, 12),
        category: 'Lazer',
      ),
      _transaction(
        id: 'planned',
        description: 'Receita prevista',
        type: TransactionType.income,
        status: TransactionStatus.previsto,
        amount: _brl(999999),
        occurredAt: DateTime(2026, 9, 20),
        category: 'Renda',
      ),
      _transaction(
        id: 'transfer',
        description: 'Reserva',
        type: TransactionType.transfer,
        amount: _brl(50000),
        occurredAt: DateTime(2026, 8, 15),
        counterAccountId: 'savings',
      ),
      _transaction(
        id: 'canceled',
        description: 'Compra cancelada',
        type: TransactionType.expense,
        status: TransactionStatus.cancelado,
        amount: _brl(30000),
        occurredAt: DateTime(2026, 9, 4),
        category: 'Outros',
      ),
      ReportTransactionRecord(
        id: 'usd-income',
        description: 'USD income',
        type: TransactionType.income,
        status: TransactionStatus.conciliado,
        amount: _usd(25000),
        accountId: 'usd',
        occurredAt: DateTime(2026, 9, 2),
        category: 'Income',
      ),
    ],
  );
}

ReportTransactionRecord _transaction({
  required String id,
  required String description,
  required TransactionType type,
  required Money amount,
  required DateTime occurredAt,
  TransactionStatus status = TransactionStatus.compensado,
  String accountId = 'checking',
  String? counterAccountId,
  String? category,
}) => ReportTransactionRecord(
  id: id,
  description: description,
  type: type,
  status: status,
  amount: amount,
  accountId: accountId,
  counterAccountId: counterAccountId,
  occurredAt: occurredAt,
  category: category,
);

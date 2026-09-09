import 'package:drift/drift.dart';

import '../../../core/ledger/balance_rules.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/data/local_database.dart';
import '../domain/financial_transaction.dart';
import '../domain/transaction_repository.dart';

class DriftTransactionRepository implements TransactionRepository {
  const DriftTransactionRepository(this._database);

  final LocalDatabase _database;

  @override
  Future<List<FinancialTransaction>> findAll() async {
    final query = _database.select(_database.transactionEntries)
      ..orderBy([
        (row) => OrderingTerm.desc(row.occurredAtMicros),
        (row) => OrderingTerm.desc(row.id),
      ]);
    return (await query.get()).map(_toDomain).toList(growable: false);
  }

  @override
  Future<FinancialTransaction?> findById(String id) async {
    final query = _database.select(_database.transactionEntries)
      ..where((row) => row.id.equals(id));
    final stored = await query.getSingleOrNull();
    return stored == null ? null : _toDomain(stored);
  }

  @override
  Future<void> add(FinancialTransaction transaction) async {
    if (await findById(transaction.id) != null) {
      throw StateError('Transaction already exists: ${transaction.id}');
    }
    await _database
        .into(_database.transactionEntries)
        .insert(_toCompanion(transaction));
  }

  @override
  Future<void> addAll(List<FinancialTransaction> transactions) async {
    await _database.transaction(() async {
      for (final transaction in transactions) {
        await _database
            .into(_database.transactionEntries)
            .insert(_toCompanion(transaction), mode: InsertMode.insert);
      }
    });
  }

  @override
  Future<void> replace(FinancialTransaction transaction) async {
    final updated =
        await (_database.update(_database.transactionEntries)
              ..where((row) => row.id.equals(transaction.id)))
            .write(_toCompanion(transaction));
    if (updated == 0) {
      throw StateError('Transaction ${transaction.id} does not exist');
    }
  }

  FinancialTransaction _toDomain(StoredTransaction stored) {
    final currency = Currency(
      code: stored.currencyCode,
      decimalDigits: stored.currencyDecimalDigits,
      symbol: stored.currencySymbol,
    );
    return FinancialTransaction(
      id: stored.id,
      description: stored.description,
      type: TransactionType.values.byName(stored.type),
      status: TransactionStatus.values.byName(stored.status),
      amount: Money(minorUnits: stored.amountMinor, currency: currency),
      accountId: stored.accountId,
      counterAccountId: stored.counterAccountId,
      occurredAt: DateTime.fromMicrosecondsSinceEpoch(stored.occurredAtMicros),
      category: stored.category,
      note: stored.note,
      installmentGroupId: stored.installmentGroupId,
      installmentNumber: stored.installmentNumber,
      installmentCount: stored.installmentCount,
      purchaseTotal: stored.purchaseTotalMinor == null
          ? null
          : Money(minorUnits: stored.purchaseTotalMinor!, currency: currency),
      statementId: stored.statementId,
    );
  }

  TransactionEntriesCompanion _toCompanion(FinancialTransaction transaction) =>
      TransactionEntriesCompanion.insert(
        id: transaction.id,
        description: transaction.description,
        type: transaction.type.name,
        status: transaction.status.name,
        amountMinor: transaction.amount.minorUnits,
        currencyCode: transaction.amount.currency.code,
        currencyDecimalDigits: transaction.amount.currency.decimalDigits,
        currencySymbol: transaction.amount.currency.symbol,
        accountId: transaction.accountId,
        counterAccountId: Value(transaction.counterAccountId),
        occurredAtMicros: transaction.occurredAt.microsecondsSinceEpoch,
        category: Value(transaction.category),
        note: Value(transaction.note),
        installmentGroupId: Value(transaction.installmentGroupId),
        installmentNumber: Value(transaction.installmentNumber),
        installmentCount: Value(transaction.installmentCount),
        purchaseTotalMinor: Value(transaction.purchaseTotal?.minorUnits),
        statementId: Value(transaction.statementId),
      );
}

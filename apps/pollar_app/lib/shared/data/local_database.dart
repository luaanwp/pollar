import 'package:drift/drift.dart';

part 'local_database.g.dart';

@DataClassName('StoredAccount')
class AccountEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get currencyCode => text()();
  IntColumn get currencyDecimalDigits => integer()();
  TextColumn get currencySymbol => text()();
  IntColumn get openingBalanceMinor => integer()();
  TextColumn get status => text()();
  IntColumn get creditLimitMinor => integer().nullable()();
  IntColumn get closingDay => integer().nullable()();
  IntColumn get dueDay => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StoredTransaction')
class TransactionEntries extends Table {
  TextColumn get id => text()();
  TextColumn get description => text()();
  TextColumn get type => text()();
  TextColumn get status => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text()();
  IntColumn get currencyDecimalDigits => integer()();
  TextColumn get currencySymbol => text()();
  @ReferenceName('sourceTransactions')
  TextColumn get accountId => text().references(AccountEntries, #id)();

  @ReferenceName('counterTransactions')
  TextColumn get counterAccountId =>
      text().nullable().references(AccountEntries, #id)();
  IntColumn get occurredAtMicros => integer()();
  TextColumn get category => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get installmentGroupId => text().nullable()();
  IntColumn get installmentNumber => integer().nullable()();
  IntColumn get installmentCount => integer().nullable()();
  IntColumn get purchaseTotalMinor => integer().nullable()();
  TextColumn get statementId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [AccountEntries, TransactionEntries])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(transactionEntries);
      }
      if (from >= 2 && from < 3) {
        await migrator.addColumn(
          transactionEntries,
          transactionEntries.installmentGroupId,
        );
        await migrator.addColumn(
          transactionEntries,
          transactionEntries.installmentNumber,
        );
        await migrator.addColumn(
          transactionEntries,
          transactionEntries.installmentCount,
        );
        await migrator.addColumn(
          transactionEntries,
          transactionEntries.purchaseTotalMinor,
        );
        await migrator.addColumn(
          transactionEntries,
          transactionEntries.statementId,
        );
      }
    },
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}

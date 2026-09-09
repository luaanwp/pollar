import 'package:drift/drift.dart';

part 'account_database.g.dart';

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

@DriftDatabase(tables: [AccountEntries])
class AccountDatabase extends _$AccountDatabase {
  AccountDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (migrator) => migrator.createAll());
}

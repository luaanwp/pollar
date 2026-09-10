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

@DataClassName('StoredBudget')
class BudgetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  IntColumn get monthMicros => integer()();
  IntColumn get limitMinor => integer()();
  TextColumn get currencyCode => text()();
  IntColumn get currencyDecimalDigits => integer()();
  TextColumn get currencySymbol => text()();
  IntColumn get alertThreshold => integer().withDefault(const Constant(85))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StoredRecurringRule')
class RecurringRuleEntries extends Table {
  TextColumn get id => text()();
  TextColumn get description => text()();
  TextColumn get kind => text()();
  TextColumn get frequency => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text()();
  IntColumn get currencyDecimalDigits => integer()();
  TextColumn get currencySymbol => text()();
  TextColumn get accountId => text().references(AccountEntries, #id)();
  TextColumn get category => text().nullable()();
  IntColumn get firstDueAtMicros => integer()();
  IntColumn get remindDaysBefore => integer().withDefault(const Constant(3))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StoredWealthGoal')
class WealthGoalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetMinor => integer()();
  IntColumn get savedMinor => integer()();
  TextColumn get currencyCode => text()();
  IntColumn get currencyDecimalDigits => integer()();
  TextColumn get currencySymbol => text()();
  IntColumn get createdAtMicros => integer()();
  IntColumn get deadlineMicros => integer().nullable()();
  BoolColumn get priority => boolean().withDefault(const Constant(false))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StoredWealthAsset')
class WealthAssetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  IntColumn get currentValueMinor => integer()();
  TextColumn get currencyCode => text()();
  IntColumn get currencyDecimalDigits => integer()();
  TextColumn get currencySymbol => text()();
  IntColumn get valuedAtMicros => integer()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StoredWealthDebt')
class WealthDebtEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  IntColumn get originalAmountMinor => integer()();
  IntColumn get outstandingAmountMinor => integer()();
  TextColumn get currencyCode => text()();
  IntColumn get currencyDecimalDigits => integer()();
  TextColumn get currencySymbol => text()();
  IntColumn get annualInterestBasisPoints =>
      integer().withDefault(const Constant(0))();
  IntColumn get dueDateMicros => integer().nullable()();
  IntColumn get updatedAtMicros => integer()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    AccountEntries,
    TransactionEntries,
    BudgetEntries,
    RecurringRuleEntries,
    WealthGoalEntries,
    WealthAssetEntries,
    WealthDebtEntries,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(super.executor);

  @override
  int get schemaVersion => 5;

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
      if (from < 4) {
        await migrator.createTable(budgetEntries);
        await migrator.createTable(recurringRuleEntries);
      }
      if (from < 5) {
        await migrator.createTable(wealthGoalEntries);
        await migrator.createTable(wealthAssetEntries);
        await migrator.createTable(wealthDebtEntries);
      }
    },
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}

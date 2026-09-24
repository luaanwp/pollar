import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/data/local_backup_data_source.dart';
import 'package:pollar_app/features/accounts/data/drift_account_repository.dart';
import 'package:pollar_app/features/data_management/domain/data_backup.dart';
import 'package:pollar_app/shared/data/local_database.dart';

void main() {
  late LocalDatabase database;
  late LocalBackupDataSource source;

  setUp(() async {
    database = LocalDatabase(NativeDatabase.memory());
    source = LocalBackupDataSource(database, DriftAccountRepository(database));
    await database
        .into(database.accountEntries)
        .insert(_account.toCompanion(true));
    await database
        .into(database.transactionEntries)
        .insert(_transaction.toCompanion(true));
  });

  tearDown(() => database.close());

  test('exports stable rows and restores them transactionally', () async {
    final backup = await source.exportTables();
    expect((await source.inventory()).totalRecords, 2);
    expect(backup['accounts']!.single['id'], 'account-1');
    expect(backup['transactions']!.single['accountId'], 'account-1');

    await database.delete(database.transactionEntries).go();
    await database.delete(database.accountEntries).go();
    await source.restoreTables(backup);

    expect(await database.select(database.accountEntries).get(), [_account]);
    expect(await database.select(database.transactionEntries).get(), [
      _transaction,
    ]);
  });

  test('rejects broken references before replacing current data', () async {
    final backup = await source.exportTables();
    backup['transactions']!.single['accountId'] = 'missing-account';

    expect(
      source.restoreTables(backup),
      throwsA(isA<BackupValidationException>()),
    );
    expect(
      (await database.select(database.accountEntries).get()).single.id,
      'account-1',
    );
    expect(
      (await database.select(database.transactionEntries).get()).single.id,
      'transaction-1',
    );
  });

  test('rejects duplicate ids before replacing current data', () async {
    final backup = await source.exportTables();
    backup['accounts'] = [
      ...backup['accounts']!,
      Map.of(backup['accounts']!.single),
    ];

    expect(
      source.restoreTables(backup),
      throwsA(isA<BackupValidationException>()),
    );
    expect(await database.select(database.accountEntries).get(), hasLength(1));
  });

  test('rejects invalid domain values before replacing current data', () async {
    final backup = await source.exportTables();
    backup['transactions']!.single['status'] = 'desconhecido';

    expect(
      () => source.validateTables(backup),
      throwsA(isA<BackupValidationException>()),
    );
    expect(
      (await database.select(database.transactionEntries).get()).single.status,
      'compensado',
    );
  });

  test(
    'rejects a transaction whose currency differs from its account',
    () async {
      final backup = await source.exportTables();
      backup['transactions']!.single
        ..['currencyCode'] = 'USD'
        ..['currencySymbol'] = r'$';

      expect(
        () => source.validateTables(backup),
        throwsA(isA<BackupValidationException>()),
      );
      expect(
        (await database.select(database.transactionEntries).get())
            .single
            .currencyCode,
        'BRL',
      );
    },
  );
}

const _account = StoredAccount(
  id: 'account-1',
  name: 'Conta principal',
  type: 'checking',
  currencyCode: 'BRL',
  currencyDecimalDigits: 2,
  currencySymbol: r'R$',
  openingBalanceMinor: 100000,
  status: 'active',
);

const _transaction = StoredTransaction(
  id: 'transaction-1',
  description: 'Mercado',
  type: 'expense',
  status: 'compensado',
  amountMinor: 12345,
  currencyCode: 'BRL',
  currencyDecimalDigits: 2,
  currencySymbol: r'R$',
  accountId: 'account-1',
  occurredAtMicros: 1770000000000000,
  category: 'Alimentação',
);

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/shared/data/local_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('schema 1 accounts migrate to schema 2 without data loss', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'pollar-local-database-migration-',
    );
    final file = File(
      '${tempDirectory.path}${Platform.pathSeparator}pollar.sqlite',
    );
    final legacy = sqlite.sqlite3.open(file.path);
    legacy.execute('''
      CREATE TABLE account_entries (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        currency_code TEXT NOT NULL,
        currency_decimal_digits INTEGER NOT NULL,
        currency_symbol TEXT NOT NULL,
        opening_balance_minor INTEGER NOT NULL,
        status TEXT NOT NULL,
        credit_limit_minor INTEGER NULL,
        closing_day INTEGER NULL,
        due_day INTEGER NULL
      );
    ''');
    legacy.execute('''
      INSERT INTO account_entries VALUES (
        'legacy', 'Conta antiga', 'checking', 'BRL', 2, 'R\$', 10000,
        'active', NULL, NULL, NULL
      );
    ''');
    legacy.execute('PRAGMA user_version = 1;');
    legacy.close();

    final database = LocalDatabase(NativeDatabase(file));
    addTearDown(database.close);
    final accounts = await database.select(database.accountEntries).get();
    final transactions = await database
        .select(database.transactionEntries)
        .get();

    expect(accounts.single.id, 'legacy');
    expect(accounts.single.name, 'Conta antiga');
    expect(transactions, isEmpty);
    expect(database.schemaVersion, 2);

    await database.close();
    final resolvedTemp = tempDirectory.absolute.path;
    final resolvedSystemTemp = Directory.systemTemp.absolute.path;
    if (!resolvedTemp.startsWith(resolvedSystemTemp)) {
      fail('Refusing to clean a directory outside the system temp folder');
    }
    await tempDirectory.delete(recursive: true);
  });
}

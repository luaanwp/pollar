import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/accounts/data/drift_account_repository.dart';
import 'package:pollar_app/features/accounts/domain/account.dart';
import 'package:pollar_app/shared/data/local_database.dart';

void main() {
  late LocalDatabase database;

  Account account(
    String id,
    AccountType type, {
    AccountStatus status = AccountStatus.active,
  }) {
    final isCard = type == AccountType.creditCard;
    return Account(
      id: id,
      name: 'Conta $id',
      type: type,
      currency: Currency.usd,
      openingBalance: const Money(minorUnits: 12345, currency: Currency.usd),
      status: status,
      creditCardTerms: isCard
          ? CreditCardTerms(
              creditLimit: const Money(
                minorUnits: 250000,
                currency: Currency.usd,
              ),
              closingDay: 12,
              dueDay: 20,
            )
          : null,
    );
  }

  tearDown(() async {
    await database.close();
  });

  test('round-trips every account type and optional card terms', () async {
    database = LocalDatabase(NativeDatabase.memory());
    final expected = AccountType.values
        .map((type) => account(type.name, type))
        .toList(growable: false);
    final repository = DriftAccountRepository(database);

    for (final value in expected) {
      await repository.add(value);
    }

    for (final value in expected) {
      expect(await repository.findById(value.id), value);
    }
    expect((await repository.findAll()).toSet(), expected.toSet());
  });

  test('replace persists status changes and rejects unknown ids', () async {
    database = LocalDatabase(NativeDatabase.memory());
    final repository = DriftAccountRepository(database);
    final original = account('main', AccountType.checking);
    await repository.add(original);

    await repository.replace(original.rename('Casa').archive());

    final stored = await repository.findById('main');
    expect(stored?.name, 'Casa');
    expect(stored?.status, AccountStatus.archived);
    expect(
      repository.replace(account('missing', AccountType.cash)),
      throwsStateError,
    );
  });

  test('initial accounts are inserted only into an empty database', () async {
    database = LocalDatabase(NativeDatabase.memory());
    final first = account('first', AccountType.cash);
    final second = account('second', AccountType.savings);

    final initialRepository = DriftAccountRepository(
      database,
      initialAccounts: [first],
    );
    expect(await initialRepository.findAll(), [first]);

    final reopenedRepository = DriftAccountRepository(
      database,
      initialAccounts: [second],
    );
    expect(await reopenedRepository.findAll(), [first]);
  });

  test('data survives closing and reopening the SQLite file', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'pollar-account-repository-',
    );
    final file = File(
      '${tempDirectory.path}${Platform.pathSeparator}accounts.sqlite',
    );
    final expected = account('persistent', AccountType.investment);
    database = LocalDatabase(NativeDatabase(file));
    await DriftAccountRepository(database).add(expected);
    await database.close();

    database = LocalDatabase(NativeDatabase(file));
    expect(
      await DriftAccountRepository(database).findById(expected.id),
      expected,
    );
    await database.close();

    final resolvedTemp = tempDirectory.absolute.path;
    final resolvedSystemTemp = Directory.systemTemp.absolute.path;
    if (!resolvedTemp.startsWith(resolvedSystemTemp)) {
      fail('Refusing to clean a directory outside the system temp folder');
    }
    await tempDirectory.delete(recursive: true);
    database = LocalDatabase(NativeDatabase.memory());
  });
}

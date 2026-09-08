import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/accounts/application/account_service.dart';
import 'package:pollar_app/features/accounts/data/in_memory_account_repository.dart';
import 'package:pollar_app/features/accounts/domain/account.dart';

void main() {
  Account account(String id, {AccountStatus status = AccountStatus.active}) =>
      Account(
        id: id,
        name: 'Conta $id',
        type: AccountType.checking,
        currency: Currency.brl,
        openingBalance: const Money.zero(Currency.brl),
        status: status,
      );

  test(
    'creates and retrieves an account through the repository boundary',
    () async {
      final repository = InMemoryAccountRepository();
      final service = AccountService(repository);

      final created = await service.create(account('one'));

      expect(created.id, 'one');
      expect(await repository.findById('one'), created);
      expect(await service.list(), [created]);
    },
  );

  test('rejects duplicate ids before writing', () async {
    final service = AccountService(
      InMemoryAccountRepository(seed: [account('one')]),
    );

    expect(
      service.create(account('one')),
      throwsA(isA<AccountAlreadyExistsException>()),
    );
  });

  test('active listing hides archived accounts by default', () async {
    final active = account('active');
    final archived = account('archived', status: AccountStatus.archived);
    final service = AccountService(
      InMemoryAccountRepository(seed: [active, archived]),
    );

    expect(await service.list(), [active]);
    expect(await service.list(includeArchived: true), [active, archived]);
  });

  test(
    'rename, archive and restore preserve identity and persist state',
    () async {
      final repository = InMemoryAccountRepository(seed: [account('one')]);
      final service = AccountService(repository);

      final renamed = await service.rename('one', 'Conta de casa');
      final archived = await service.archive('one');
      final archivedAgain = await service.archive('one');
      final restored = await service.restore('one');

      expect(renamed.name, 'Conta de casa');
      expect(archived.id, 'one');
      expect(archived.isArchived, isTrue);
      expect(archivedAgain, archived);
      expect(restored.status, AccountStatus.active);
      expect(await repository.findById('one'), restored);
    },
  );

  test('mutations fail explicitly for an unknown account', () async {
    final service = AccountService(InMemoryAccountRepository());

    expect(
      service.rename('missing', 'Nova conta'),
      throwsA(isA<AccountNotFoundException>()),
    );
    expect(
      service.archive('missing'),
      throwsA(isA<AccountNotFoundException>()),
    );
    expect(
      service.restore('missing'),
      throwsA(isA<AccountNotFoundException>()),
    );
  });

  test(
    'seed and direct writes enforce repository identity invariants',
    () async {
      expect(
        () => InMemoryAccountRepository(seed: [account('one'), account('one')]),
        throwsArgumentError,
      );

      final repository = InMemoryAccountRepository(seed: [account('one')]);
      expect(repository.add(account('one')), throwsStateError);
      expect(repository.replace(account('missing')), throwsStateError);
    },
  );
}

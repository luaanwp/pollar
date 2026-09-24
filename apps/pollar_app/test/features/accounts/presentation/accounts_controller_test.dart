import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/accounts/domain/account.dart';
import 'package:pollar_app/features/accounts/domain/account_repository.dart';
import 'package:pollar_app/features/accounts/presentation/accounts_controller.dart';
import 'package:pollar_app/shared/application/financial_data_revision.dart';

void main() {
  test('reloads accounts after a shared financial revision', () async {
    final repository = _MutableAccountRepository([_account('before')]);
    final container = ProviderContainer(
      overrides: [accountRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect((await container.read(accountsProvider.future)).single.id, 'before');

    repository.accounts = [_account('after')];
    container.read(financialDataRevisionProvider.notifier).bump();

    expect((await container.read(accountsProvider.future)).single.id, 'after');
    expect(repository.loadCount, 2);
  });
}

Account _account(String id) => Account(
  id: id,
  name: 'Conta $id',
  type: AccountType.checking,
  currency: Currency.brl,
  openingBalance: const Money(minorUnits: 0, currency: Currency.brl),
);

class _MutableAccountRepository implements AccountRepository {
  _MutableAccountRepository(this.accounts);

  List<Account> accounts;
  var loadCount = 0;

  @override
  Future<List<Account>> findAll() async {
    loadCount++;
    return List.unmodifiable(accounts);
  }

  @override
  Future<Account?> findById(String id) async {
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  @override
  Future<void> add(Account account) async => accounts = [...accounts, account];

  @override
  Future<void> replace(Account account) async => accounts = [
    for (final current in accounts)
      if (current.id == account.id) account else current,
  ];
}

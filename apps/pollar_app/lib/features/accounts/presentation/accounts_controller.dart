import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/account_service.dart';
import '../domain/account.dart';
import '../domain/account_repository.dart';

/// Overridden by the app composition root and by tests.
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  throw StateError('AccountRepository was not configured');
});

final accountServiceProvider = Provider<AccountService>(
  (ref) => AccountService(ref.watch(accountRepositoryProvider)),
);

final accountsProvider =
    AsyncNotifierProvider<AccountsController, List<Account>>(
      AccountsController.new,
    );

class AccountsController extends AsyncNotifier<List<Account>> {
  AccountService get _service => ref.read(accountServiceProvider);

  @override
  Future<List<Account>> build() => _service.list(includeArchived: true);

  Future<void> create(Account account) async {
    await _service.create(account);
    state = AsyncData(await _service.list(includeArchived: true));
  }

  Future<void> archive(String id) async {
    await _service.archive(id);
    state = AsyncData(await _service.list(includeArchived: true));
  }

  Future<void> restore(String id) async {
    await _service.restore(id);
    state = AsyncData(await _service.list(includeArchived: true));
  }
}

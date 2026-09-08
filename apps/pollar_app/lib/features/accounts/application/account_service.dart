import '../domain/account.dart';
import '../domain/account_repository.dart';

class AccountAlreadyExistsException implements Exception {
  const AccountAlreadyExistsException(this.id);

  final String id;

  @override
  String toString() => 'AccountAlreadyExistsException: $id';
}

class AccountNotFoundException implements Exception {
  const AccountNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'AccountNotFoundException: $id';
}

/// Account use cases, independent from Flutter and the persistence mechanism.
class AccountService {
  const AccountService(this._repository);

  final AccountRepository _repository;

  Future<List<Account>> list({bool includeArchived = false}) async {
    final accounts = await _repository.findAll();
    final visible = includeArchived
        ? accounts
        : accounts.where((account) => !account.isArchived);
    return List.unmodifiable(visible);
  }

  Future<Account> create(Account account) async {
    if (await _repository.findById(account.id) != null) {
      throw AccountAlreadyExistsException(account.id);
    }
    await _repository.add(account);
    return account;
  }

  Future<Account> rename(String id, String name) async {
    final account = await _required(id);
    final updated = account.rename(name);
    await _repository.replace(updated);
    return updated;
  }

  Future<Account> archive(String id) async {
    final account = await _required(id);
    if (account.isArchived) return account;
    final updated = account.archive();
    await _repository.replace(updated);
    return updated;
  }

  Future<Account> restore(String id) async {
    final account = await _required(id);
    if (!account.isArchived) return account;
    final updated = account.restore();
    await _repository.replace(updated);
    return updated;
  }

  Future<Account> _required(String id) async {
    final account = await _repository.findById(id);
    if (account == null) throw AccountNotFoundException(id);
    return account;
  }
}

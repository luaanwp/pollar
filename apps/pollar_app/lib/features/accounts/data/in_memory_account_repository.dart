import '../domain/account.dart';
import '../domain/account_repository.dart';

/// Deterministic repository used until the local Drift adapter lands.
class InMemoryAccountRepository implements AccountRepository {
  InMemoryAccountRepository({Iterable<Account> seed = const []}) {
    for (final account in seed) {
      if (_accounts.containsKey(account.id)) {
        throw ArgumentError.value(account.id, 'seed', 'Duplicate account id');
      }
      _accounts[account.id] = account;
    }
  }

  final Map<String, Account> _accounts = {};

  @override
  Future<void> add(Account account) async {
    if (_accounts.containsKey(account.id)) {
      throw StateError('Account already exists: ${account.id}');
    }
    _accounts[account.id] = account;
  }

  @override
  Future<List<Account>> findAll() async => List.unmodifiable(_accounts.values);

  @override
  Future<Account?> findById(String id) async => _accounts[id];

  @override
  Future<void> replace(Account account) async {
    if (!_accounts.containsKey(account.id)) {
      throw StateError('Account does not exist: ${account.id}');
    }
    _accounts[account.id] = account;
  }
}

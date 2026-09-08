import 'account.dart';

/// Persistence boundary for accounts.
///
/// Implementations may use memory, Drift or a remote source without exposing
/// storage details to application code.
abstract interface class AccountRepository {
  Future<List<Account>> findAll();

  Future<Account?> findById(String id);

  Future<void> add(Account account);

  Future<void> replace(Account account);
}

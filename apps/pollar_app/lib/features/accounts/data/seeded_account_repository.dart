import 'default_accounts.dart';
import 'in_memory_account_repository.dart';

/// Creates the deterministic account source used by widget and golden tests.
InMemoryAccountRepository createSeededAccountRepository() =>
    InMemoryAccountRepository(seed: createDefaultAccounts());

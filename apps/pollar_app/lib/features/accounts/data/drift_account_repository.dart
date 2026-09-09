import 'package:drift/drift.dart';

import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/data/local_database.dart';
import '../domain/account.dart';
import '../domain/account_repository.dart';

/// SQLite-backed account adapter. Domain and application layers remain storage
/// agnostic and depend only on [AccountRepository].
class DriftAccountRepository implements AccountRepository {
  DriftAccountRepository(
    this._database, {
    Iterable<Account> initialAccounts = const [],
  }) : _initialAccounts = List.unmodifiable(initialAccounts);

  final LocalDatabase _database;
  final List<Account> _initialAccounts;
  Future<void>? _initialization;

  @override
  Future<List<Account>> findAll() async {
    await _ensureInitialized();
    final query = _database.select(_database.accountEntries)
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    return (await query.get()).map(_toDomain).toList(growable: false);
  }

  @override
  Future<Account?> findById(String id) async {
    await _ensureInitialized();
    final query = _database.select(_database.accountEntries)
      ..where((row) => row.id.equals(id));
    final stored = await query.getSingleOrNull();
    return stored == null ? null : _toDomain(stored);
  }

  @override
  Future<void> add(Account account) async {
    await _ensureInitialized();
    await _database
        .into(_database.accountEntries)
        .insert(_toCompanion(account));
  }

  @override
  Future<void> replace(Account account) async {
    await _ensureInitialized();
    final updated = await (_database.update(
      _database.accountEntries,
    )..where((row) => row.id.equals(account.id))).write(_toCompanion(account));
    if (updated == 0) {
      throw StateError('Account ${account.id} does not exist');
    }
  }

  Future<void> _ensureInitialized() => _initialization ??= _seedNewDatabase();

  Future<void> _seedNewDatabase() async {
    if (_initialAccounts.isEmpty) return;
    final countExpression = _database.accountEntries.id.count();
    final countQuery = _database.selectOnly(_database.accountEntries)
      ..addColumns([countExpression]);
    final count = (await countQuery.getSingle()).read(countExpression) ?? 0;
    if (count != 0) return;

    await _database.batch((batch) {
      batch.insertAll(
        _database.accountEntries,
        _initialAccounts.map(_toCompanion).toList(growable: false),
      );
    });
  }

  Account _toDomain(StoredAccount stored) {
    final currency = Currency(
      code: stored.currencyCode,
      decimalDigits: stored.currencyDecimalDigits,
      symbol: stored.currencySymbol,
    );
    final type = AccountType.values.byName(stored.type);
    final hasCardTerms =
        stored.creditLimitMinor != null ||
        stored.closingDay != null ||
        stored.dueDay != null;
    if (hasCardTerms &&
        (stored.creditLimitMinor == null ||
            stored.closingDay == null ||
            stored.dueDay == null)) {
      throw StateError('Account ${stored.id} has incomplete card terms');
    }

    return Account(
      id: stored.id,
      name: stored.name,
      type: type,
      currency: currency,
      openingBalance: Money(
        minorUnits: stored.openingBalanceMinor,
        currency: currency,
      ),
      status: AccountStatus.values.byName(stored.status),
      creditCardTerms: hasCardTerms
          ? CreditCardTerms(
              creditLimit: Money(
                minorUnits: stored.creditLimitMinor!,
                currency: currency,
              ),
              closingDay: stored.closingDay!,
              dueDay: stored.dueDay!,
            )
          : null,
    );
  }

  AccountEntriesCompanion _toCompanion(Account account) {
    final terms = account.creditCardTerms;
    return AccountEntriesCompanion.insert(
      id: account.id,
      name: account.name,
      type: account.type.name,
      currencyCode: account.currency.code,
      currencyDecimalDigits: account.currency.decimalDigits,
      currencySymbol: account.currency.symbol,
      openingBalanceMinor: account.openingBalance.minorUnits,
      status: account.status.name,
      creditLimitMinor: Value(terms?.creditLimit.minorUnits),
      closingDay: Value(terms?.closingDay),
      dueDay: Value(terms?.dueDay),
    );
  }
}

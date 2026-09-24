import 'package:drift/drift.dart';

import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/application/local_mutation_recorder.dart';
import '../../../shared/data/local_database.dart';
import '../domain/account.dart';
import '../domain/account_repository.dart';

/// SQLite-backed account adapter. Domain and application layers remain storage
/// agnostic and depend only on [AccountRepository].
class DriftAccountRepository implements AccountRepository {
  DriftAccountRepository(
    this._database, {
    Iterable<Account> initialAccounts = const [],
    this._mutationRecorder = const NoopLocalMutationRecorder(),
  }) : _initialAccounts = List.unmodifiable(initialAccounts);

  final LocalDatabase _database;
  final List<Account> _initialAccounts;
  final LocalMutationRecorder _mutationRecorder;
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
    await _database.transaction(() async {
      await _database
          .into(_database.accountEntries)
          .insert(_toCompanion(account));
      await _record(account);
    });
  }

  @override
  Future<void> replace(Account account) async {
    await _ensureInitialized();
    await _database.transaction(() async {
      final updated =
          await (_database.update(_database.accountEntries)
                ..where((row) => row.id.equals(account.id)))
              .write(_toCompanion(account));
      if (updated == 0) {
        throw StateError('Account ${account.id} does not exist');
      }
      await _record(account);
    });
  }

  Future<void> _ensureInitialized() => _initialization ??= _seedNewDatabase();

  Future<void> _seedNewDatabase() async {
    if (_initialAccounts.isEmpty) return;
    final countExpression = _database.accountEntries.id.count();
    final countQuery = _database.selectOnly(_database.accountEntries)
      ..addColumns([countExpression]);
    final count = (await countQuery.getSingle()).read(countExpression) ?? 0;
    if (count != 0) return;

    await _database.transaction(() async {
      for (final account in _initialAccounts) {
        await _database
            .into(_database.accountEntries)
            .insert(_toCompanion(account));
        await _record(account);
      }
    });
  }

  Future<void> _record(Account account) => _mutationRecorder.recordUpsert(
    entityType: 'account',
    entityId: account.id,
    payload: {
      'id': account.id,
      'name': account.name,
      'type': account.type.name,
      'currency_code': account.currency.code,
      'currency_decimal_digits': account.currency.decimalDigits,
      'currency_symbol': account.currency.symbol,
      'opening_balance_minor': account.openingBalance.minorUnits,
      'status': account.status.name,
      'credit_limit_minor': account.creditCardTerms?.creditLimit.minorUnits,
      'closing_day': account.creditCardTerms?.closingDay,
      'due_day': account.creditCardTerms?.dueDay,
    },
  );

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

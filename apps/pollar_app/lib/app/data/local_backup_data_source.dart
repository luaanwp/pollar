import '../../core/ledger/balance_rules.dart';
import '../../core/money/currency.dart';
import '../../core/money/money.dart';
import '../../features/accounts/domain/account.dart';
import '../../features/accounts/domain/account_repository.dart';
import '../../features/data_management/application/backup_data_source.dart';
import '../../features/data_management/domain/data_backup.dart';
import '../../features/planning/domain/budget.dart';
import '../../features/planning/domain/recurring_rule.dart';
import '../../features/transactions/domain/financial_transaction.dart';
import '../../features/wealth/domain/wealth_asset.dart';
import '../../features/wealth/domain/wealth_debt.dart';
import '../../features/wealth/domain/wealth_goal.dart';
import '../../shared/application/local_mutation_recorder.dart';
import '../../shared/data/local_database.dart';

class LocalBackupDataSource implements BackupDataSource {
  LocalBackupDataSource(
    this._database,
    this._accounts, {
    this.mutationRecorder = const NoopLocalMutationRecorder(),
  });

  final LocalDatabase _database;
  final AccountRepository _accounts;
  final LocalMutationRecorder mutationRecorder;

  @override
  Future<DataInventory> inventory() async {
    await _accounts.findAll();
    final tables = await exportTables();
    return DataInventory(
      accounts: tables['accounts']!.length,
      transactions: tables['transactions']!.length,
      budgets: tables['budgets']!.length,
      recurringRules: tables['recurring_rules']!.length,
      wealthGoals: tables['wealth_goals']!.length,
      wealthAssets: tables['wealth_assets']!.length,
      wealthDebts: tables['wealth_debts']!.length,
    );
  }

  @override
  Future<Map<String, List<Map<String, Object?>>>> exportTables() async {
    await _accounts.findAll();
    final accounts = await _database.select(_database.accountEntries).get()
      ..sort((a, b) => a.id.compareTo(b.id));
    final transactions =
        await _database.select(_database.transactionEntries).get()
          ..sort((a, b) => a.id.compareTo(b.id));
    final budgets = await _database.select(_database.budgetEntries).get()
      ..sort((a, b) => a.id.compareTo(b.id));
    final recurringRules =
        await _database.select(_database.recurringRuleEntries).get()
          ..sort((a, b) => a.id.compareTo(b.id));
    final goals = await _database.select(_database.wealthGoalEntries).get()
      ..sort((a, b) => a.id.compareTo(b.id));
    final assets = await _database.select(_database.wealthAssetEntries).get()
      ..sort((a, b) => a.id.compareTo(b.id));
    final debts = await _database.select(_database.wealthDebtEntries).get()
      ..sort((a, b) => a.id.compareTo(b.id));

    List<Map<String, Object?>> jsonRows(Iterable<dynamic> rows) => rows
        .map((row) => Map<String, Object?>.from(row.toJson() as Map))
        .toList(growable: false);

    return {
      'accounts': jsonRows(accounts),
      'transactions': jsonRows(transactions),
      'budgets': jsonRows(budgets),
      'recurring_rules': jsonRows(recurringRules),
      'wealth_goals': jsonRows(goals),
      'wealth_assets': jsonRows(assets),
      'wealth_debts': jsonRows(debts),
    };
  }

  @override
  void validateTables(Map<String, List<Map<String, Object?>>> tables) {
    _decodeAndValidate(tables);
  }

  @override
  Future<void> restoreTables(
    Map<String, List<Map<String, Object?>>> tables,
  ) async {
    try {
      final (
        :accounts,
        :transactions,
        :budgets,
        :recurringRules,
        :goals,
        :assets,
        :debts,
      ) = _decodeAndValidate(
        tables,
      );

      await _database.transaction(() async {
        await _database.delete(_database.syncOutboxEntries).go();
        await _database.delete(_database.syncMetadataEntries).go();
        await _database.delete(_database.syncConflictEntries).go();
        await _database.delete(_database.syncRuntimeEntries).go();
        await _database.delete(_database.transactionEntries).go();
        await _database.delete(_database.recurringRuleEntries).go();
        await _database.delete(_database.budgetEntries).go();
        await _database.delete(_database.wealthGoalEntries).go();
        await _database.delete(_database.wealthAssetEntries).go();
        await _database.delete(_database.wealthDebtEntries).go();
        await _database.delete(_database.accountEntries).go();

        for (final row in accounts) {
          await _database
              .into(_database.accountEntries)
              .insert(row.toCompanion(true));
          await mutationRecorder.recordUpsert(
            entityType: 'account',
            entityId: row.id,
            payload: _accountPayload(row),
          );
        }
        for (final row in transactions) {
          await _database
              .into(_database.transactionEntries)
              .insert(row.toCompanion(true));
          await mutationRecorder.recordUpsert(
            entityType: 'transaction',
            entityId: row.id,
            payload: _transactionPayload(row),
          );
        }
        for (final row in budgets) {
          await _database
              .into(_database.budgetEntries)
              .insert(row.toCompanion(true));
        }
        for (final row in recurringRules) {
          await _database
              .into(_database.recurringRuleEntries)
              .insert(row.toCompanion(true));
        }
        for (final row in goals) {
          await _database
              .into(_database.wealthGoalEntries)
              .insert(row.toCompanion(true));
        }
        for (final row in assets) {
          await _database
              .into(_database.wealthAssetEntries)
              .insert(row.toCompanion(true));
        }
        for (final row in debts) {
          await _database
              .into(_database.wealthDebtEntries)
              .insert(row.toCompanion(true));
        }
      });
    } on BackupValidationException {
      rethrow;
    } catch (_) {
      throw const BackupValidationException(
        'O backup contém campos incompatíveis ou corrompidos.',
      );
    }
  }

  Map<String, Object?> _accountPayload(StoredAccount row) => {
    'id': row.id,
    'name': row.name,
    'type': row.type,
    'currency_code': row.currencyCode,
    'currency_decimal_digits': row.currencyDecimalDigits,
    'currency_symbol': row.currencySymbol,
    'opening_balance_minor': row.openingBalanceMinor,
    'status': row.status,
    'credit_limit_minor': row.creditLimitMinor,
    'closing_day': row.closingDay,
    'due_day': row.dueDay,
  };

  Map<String, Object?> _transactionPayload(StoredTransaction row) => {
    'id': row.id,
    'description': row.description,
    'type': row.type,
    'status': row.status,
    'amount_minor': row.amountMinor,
    'currency_code': row.currencyCode,
    'currency_decimal_digits': row.currencyDecimalDigits,
    'currency_symbol': row.currencySymbol,
    'account_id': row.accountId,
    'counter_account_id': row.counterAccountId,
    'occurred_at': DateTime.fromMicrosecondsSinceEpoch(
      row.occurredAtMicros,
      isUtc: true,
    ).toIso8601String(),
    'category': row.category,
    'note': row.note,
    'installment_group_id': row.installmentGroupId,
    'installment_number': row.installmentNumber,
    'installment_count': row.installmentCount,
    'purchase_total_minor': row.purchaseTotalMinor,
    'statement_id': row.statementId,
  };

  ({
    List<StoredAccount> accounts,
    List<StoredTransaction> transactions,
    List<StoredBudget> budgets,
    List<StoredRecurringRule> recurringRules,
    List<StoredWealthGoal> goals,
    List<StoredWealthAsset> assets,
    List<StoredWealthDebt> debts,
  })
  _decodeAndValidate(Map<String, List<Map<String, Object?>>> tables) {
    try {
      final accounts = tables['accounts']!
          .map((row) => StoredAccount.fromJson(Map<String, dynamic>.from(row)))
          .toList(growable: false);
      final transactions = tables['transactions']!
          .map(
            (row) => StoredTransaction.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList(growable: false);
      final budgets = tables['budgets']!
          .map((row) => StoredBudget.fromJson(Map<String, dynamic>.from(row)))
          .toList(growable: false);
      final recurringRules = tables['recurring_rules']!
          .map(
            (row) =>
                StoredRecurringRule.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList(growable: false);
      final goals = tables['wealth_goals']!
          .map(
            (row) => StoredWealthGoal.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList(growable: false);
      final assets = tables['wealth_assets']!
          .map(
            (row) => StoredWealthAsset.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList(growable: false);
      final debts = tables['wealth_debts']!
          .map(
            (row) => StoredWealthDebt.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList(growable: false);

      _requireUnique(accounts.map((row) => row.id), 'contas');
      _requireUnique(transactions.map((row) => row.id), 'lançamentos');
      _requireUnique(budgets.map((row) => row.id), 'orçamentos');
      _requireUnique(recurringRules.map((row) => row.id), 'recorrências');
      _requireUnique(goals.map((row) => row.id), 'metas');
      _requireUnique(assets.map((row) => row.id), 'ativos');
      _requireUnique(debts.map((row) => row.id), 'dívidas');

      final accountIds = accounts.map((row) => row.id).toSet();
      for (final transaction in transactions) {
        if (!accountIds.contains(transaction.accountId) ||
            (transaction.counterAccountId != null &&
                !accountIds.contains(transaction.counterAccountId))) {
          throw const BackupValidationException(
            'O backup contém um lançamento ligado a uma conta ausente.',
          );
        }
      }
      for (final rule in recurringRules) {
        if (!accountIds.contains(rule.accountId)) {
          throw const BackupValidationException(
            'O backup contém uma recorrência ligada a uma conta ausente.',
          );
        }
      }
      final domainAccounts = <String, Account>{};
      for (final row in accounts) {
        final currency = _currency(
          row.currencyCode,
          row.currencyDecimalDigits,
          row.currencySymbol,
        );
        final hasCardTerms =
            row.creditLimitMinor != null ||
            row.closingDay != null ||
            row.dueDay != null;
        domainAccounts[row.id] = Account(
          id: row.id,
          name: row.name,
          type: AccountType.values.byName(row.type),
          currency: currency,
          openingBalance: Money(
            minorUnits: row.openingBalanceMinor,
            currency: currency,
          ),
          status: AccountStatus.values.byName(row.status),
          creditCardTerms: hasCardTerms
              ? CreditCardTerms(
                  creditLimit: Money(
                    minorUnits: row.creditLimitMinor!,
                    currency: currency,
                  ),
                  closingDay: row.closingDay!,
                  dueDay: row.dueDay!,
                )
              : null,
        );
      }
      for (final row in transactions) {
        final currency = _currency(
          row.currencyCode,
          row.currencyDecimalDigits,
          row.currencySymbol,
        );
        final transaction = FinancialTransaction(
          id: row.id,
          description: row.description,
          type: TransactionType.values.byName(row.type),
          status: TransactionStatus.values.byName(row.status),
          amount: Money(minorUnits: row.amountMinor, currency: currency),
          accountId: row.accountId,
          counterAccountId: row.counterAccountId,
          occurredAt: DateTime.fromMicrosecondsSinceEpoch(row.occurredAtMicros),
          category: row.category,
          note: row.note,
          installmentGroupId: row.installmentGroupId,
          installmentNumber: row.installmentNumber,
          installmentCount: row.installmentCount,
          purchaseTotal: row.purchaseTotalMinor == null
              ? null
              : Money(minorUnits: row.purchaseTotalMinor!, currency: currency),
          statementId: row.statementId,
        );
        _validateTransactionAccounts(transaction, domainAccounts);
      }
      for (final row in budgets) {
        final currency = _currency(
          row.currencyCode,
          row.currencyDecimalDigits,
          row.currencySymbol,
        );
        Budget(
          id: row.id,
          category: row.category,
          month: DateTime.fromMicrosecondsSinceEpoch(row.monthMicros),
          limit: Money(minorUnits: row.limitMinor, currency: currency),
          alertThreshold: row.alertThreshold,
          active: row.active,
        );
      }
      for (final row in recurringRules) {
        final currency = _currency(
          row.currencyCode,
          row.currencyDecimalDigits,
          row.currencySymbol,
        );
        RecurringRule(
          id: row.id,
          description: row.description,
          kind: RecurringKind.values.byName(row.kind),
          frequency: RecurrenceFrequency.values.byName(row.frequency),
          amount: Money(minorUnits: row.amountMinor, currency: currency),
          accountId: row.accountId,
          category: row.category,
          firstDueDate: DateTime.fromMicrosecondsSinceEpoch(
            row.firstDueAtMicros,
          ),
          remindDaysBefore: row.remindDaysBefore,
          active: row.active,
        );
      }
      for (final row in goals) {
        final currency = _currency(
          row.currencyCode,
          row.currencyDecimalDigits,
          row.currencySymbol,
        );
        WealthGoal(
          id: row.id,
          name: row.name,
          target: Money(minorUnits: row.targetMinor, currency: currency),
          saved: Money(minorUnits: row.savedMinor, currency: currency),
          createdAt: DateTime.fromMicrosecondsSinceEpoch(row.createdAtMicros),
          deadline: row.deadlineMicros == null
              ? null
              : DateTime.fromMicrosecondsSinceEpoch(row.deadlineMicros!),
          priority: row.priority,
          active: row.active,
        );
      }
      for (final row in assets) {
        final currency = _currency(
          row.currencyCode,
          row.currencyDecimalDigits,
          row.currencySymbol,
        );
        WealthAsset(
          id: row.id,
          name: row.name,
          kind: WealthAssetKind.values.byName(row.kind),
          currentValue: Money(
            minorUnits: row.currentValueMinor,
            currency: currency,
          ),
          valuedAt: DateTime.fromMicrosecondsSinceEpoch(row.valuedAtMicros),
          active: row.active,
        );
      }
      for (final row in debts) {
        final currency = _currency(
          row.currencyCode,
          row.currencyDecimalDigits,
          row.currencySymbol,
        );
        WealthDebt(
          id: row.id,
          name: row.name,
          kind: WealthDebtKind.values.byName(row.kind),
          originalAmount: Money(
            minorUnits: row.originalAmountMinor,
            currency: currency,
          ),
          outstandingAmount: Money(
            minorUnits: row.outstandingAmountMinor,
            currency: currency,
          ),
          annualInterestBasisPoints: row.annualInterestBasisPoints,
          dueDate: row.dueDateMicros == null
              ? null
              : DateTime.fromMicrosecondsSinceEpoch(row.dueDateMicros!),
          updatedAt: DateTime.fromMicrosecondsSinceEpoch(row.updatedAtMicros),
          active: row.active,
        );
      }
      return (
        accounts: accounts,
        transactions: transactions,
        budgets: budgets,
        recurringRules: recurringRules,
        goals: goals,
        assets: assets,
        debts: debts,
      );
    } on BackupValidationException {
      rethrow;
    } catch (_) {
      throw const BackupValidationException(
        'O backup contém campos incompatíveis ou corrompidos.',
      );
    }
  }

  Currency _currency(String code, int decimalDigits, String symbol) =>
      Currency(code: code, decimalDigits: decimalDigits, symbol: symbol);

  void _validateTransactionAccounts(
    FinancialTransaction transaction,
    Map<String, Account> accounts,
  ) {
    final source = accounts[transaction.accountId]!;
    final counterId = transaction.counterAccountId;
    final counter = counterId == null ? null : accounts[counterId]!;
    if (source.currency != transaction.amount.currency ||
        (counter != null && counter.currency != source.currency)) {
      throw ArgumentError(
        'Transaction and referenced account currencies must match.',
      );
    }
    switch (transaction.type) {
      case TransactionType.income:
      case TransactionType.expense:
        if (source.isCreditCard) {
          throw ArgumentError('Income and expense require a non-card account.');
        }
      case TransactionType.cardPurchase:
        if (!source.isCreditCard) {
          throw ArgumentError('Card purchases require a credit-card account.');
        }
      case TransactionType.transfer:
        if (source.isCreditCard || counter!.isCreditCard) {
          throw ArgumentError('Transfers require two non-card accounts.');
        }
      case TransactionType.cardStatementPayment:
        if (source.isCreditCard || !counter!.isCreditCard) {
          throw ArgumentError(
            'Statement payments require a bank source and card destination.',
          );
        }
    }
  }

  void _requireUnique(Iterable<String> ids, String label) {
    final seen = <String>{};
    if (ids.any((id) => id.isEmpty || !seen.add(id))) {
      throw BackupValidationException(
        'O backup contém identificadores inválidos ou repetidos em $label.',
      );
    }
  }
}

import '../../features/accounts/domain/account_repository.dart';
import '../../features/overview/application/overview_data_source.dart';
import '../../features/transactions/domain/transaction_repository.dart';

/// Composition adapter: this is the only place where overview reads both
/// accounts and transactions. The feature itself remains independent.
class DashboardOverviewDataSource implements OverviewDataSource {
  const DashboardOverviewDataSource(this._accounts, this._transactions);

  final AccountRepository _accounts;
  final TransactionRepository _transactions;

  @override
  Future<OverviewSourceData> load() async {
    final accounts = await _accounts.findAll();
    final transactions = await _transactions.findAll();
    return OverviewSourceData(
      accounts: [
        for (final account in accounts)
          OverviewAccountRecord(
            id: account.id,
            name: account.name,
            currency: account.currency,
            openingBalance: account.openingBalance,
            kind: account.isCreditCard
                ? OverviewAccountKind.creditCard
                : OverviewAccountKind.asset,
            isArchived: account.isArchived,
          ),
      ],
      transactions: [
        for (final transaction in transactions)
          OverviewTransactionRecord(
            id: transaction.id,
            description: transaction.description,
            type: transaction.type,
            status: transaction.status,
            amount: transaction.amount,
            accountId: transaction.accountId,
            counterAccountId: transaction.counterAccountId,
            occurredAt: transaction.occurredAt,
            category: transaction.category,
          ),
      ],
    );
  }
}

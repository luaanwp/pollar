import '../../features/accounts/domain/account_repository.dart';
import '../../features/reports/application/report_data_source.dart';
import '../../features/transactions/domain/transaction_repository.dart';

class ReportLedgerDataSource implements ReportDataSource {
  const ReportLedgerDataSource(this._accounts, this._transactions);

  final AccountRepository _accounts;
  final TransactionRepository _transactions;

  @override
  Future<ReportSourceData> load() async {
    final accounts = await _accounts.findAll();
    final transactions = await _transactions.findAll();
    return ReportSourceData(
      accounts: [
        for (final account in accounts)
          ReportAccountRecord(
            id: account.id,
            currency: account.currency,
            openingBalance: account.openingBalance,
            isArchived: account.isArchived,
          ),
      ],
      transactions: [
        for (final transaction in transactions)
          ReportTransactionRecord(
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

import '../../core/ledger/balance_calculator.dart';
import '../../core/money/currency.dart';
import '../../features/accounts/domain/account_repository.dart';
import '../../features/transactions/domain/transaction_repository.dart';
import '../../features/wealth/application/wealth_ledger_source.dart';

/// Composition adapter joining the ledger to wealth without feature imports
/// inside the wealth module.
class AppWealthLedgerSource implements WealthLedgerSource {
  const AppWealthLedgerSource(this._accounts, this._transactions);

  final AccountRepository _accounts;
  final TransactionRepository _transactions;

  @override
  Future<List<WealthLedgerPosition>> listConfirmedPositions() async {
    final accounts = await _accounts.findAll();
    final transactions = await _transactions.findAll();
    final postings = transactions.expand((item) => item.postings).toList();
    return [
      for (final account in accounts)
        WealthLedgerPosition(
          id: account.id,
          name: account.name,
          balance: computeAccountBalance(
            accountId: account.id,
            openingBalance: account.openingBalance,
            postings: postings,
          ).confirmed,
          isCreditCard: account.isCreditCard,
          active: !account.isArchived,
        ),
    ];
  }

  @override
  Future<List<Currency>> listCurrencies() async =>
      (await _accounts.findAll()).map((item) => item.currency).toSet().toList();
}

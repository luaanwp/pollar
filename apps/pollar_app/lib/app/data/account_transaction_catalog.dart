import '../../features/accounts/domain/account_repository.dart';
import '../../features/transactions/application/transaction_account_catalog.dart';

class AccountTransactionCatalog implements TransactionAccountCatalog {
  const AccountTransactionCatalog(this._accounts);

  final AccountRepository _accounts;

  @override
  Future<List<TransactionAccountReference>> findAll() async => [
    for (final account in await _accounts.findAll())
      TransactionAccountReference(
        id: account.id,
        name: account.name,
        currency: account.currency,
        isCreditCard: account.isCreditCard,
        isArchived: account.isArchived,
      ),
  ];
}

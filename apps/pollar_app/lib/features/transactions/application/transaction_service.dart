import '../../../core/ledger/balance_rules.dart';
import '../domain/financial_transaction.dart';
import '../domain/transaction_repository.dart';
import 'transaction_account_catalog.dart';

class TransactionAlreadyExistsException implements Exception {
  const TransactionAlreadyExistsException(this.id);
  final String id;
}

class TransactionNotFoundException implements Exception {
  const TransactionNotFoundException(this.id);
  final String id;
}

class TransactionAccountUnavailableException implements Exception {
  const TransactionAccountUnavailableException(this.id);
  final String id;
}

class TransactionAccountMismatchException implements Exception {
  const TransactionAccountMismatchException(this.message);
  final String message;
}

class TransactionService {
  const TransactionService(this._repository, this._accounts);

  final TransactionRepository _repository;
  final TransactionAccountCatalog _accounts;

  Future<List<FinancialTransaction>> list() => _repository.findAll();

  Future<List<TransactionAccountReference>> listAccounts() =>
      _accounts.findAll();

  Future<FinancialTransaction> create(FinancialTransaction transaction) async {
    if (await _repository.findById(transaction.id) != null) {
      throw TransactionAlreadyExistsException(transaction.id);
    }
    await _validateAccounts(transaction);
    await _repository.add(transaction);
    return transaction;
  }

  Future<FinancialTransaction> cancel(String id) async {
    final current = await _repository.findById(id);
    if (current == null) throw TransactionNotFoundException(id);
    if (current.isCanceled) return current;
    final canceled = current.cancel();
    await _repository.replace(canceled);
    return canceled;
  }

  Future<void> _validateAccounts(FinancialTransaction transaction) async {
    final accounts = {
      for (final item in await _accounts.findAll()) item.id: item,
    };
    final source = accounts[transaction.accountId];
    if (source == null || source.isArchived) {
      throw TransactionAccountUnavailableException(transaction.accountId);
    }
    if (source.currency != transaction.amount.currency) {
      throw const TransactionAccountMismatchException(
        'Transaction and source account currencies must match',
      );
    }

    final counterId = transaction.counterAccountId;
    final counter = counterId == null ? null : accounts[counterId];
    if (counterId != null && (counter == null || counter.isArchived)) {
      throw TransactionAccountUnavailableException(counterId);
    }
    if (counter != null && counter.currency != source.currency) {
      throw const TransactionAccountMismatchException(
        'Transfers between different currencies require an exchange rate',
      );
    }

    switch (transaction.type) {
      case TransactionType.income:
        if (source.isCreditCard) {
          throw const TransactionAccountMismatchException(
            'Income requires a non-credit account',
          );
        }
      case TransactionType.expense:
        if (source.isCreditCard) {
          throw const TransactionAccountMismatchException(
            'Credit-card expenses must be card purchases',
          );
        }
      case TransactionType.cardPurchase:
        if (!source.isCreditCard) {
          throw const TransactionAccountMismatchException(
            'Card purchases require a credit-card account',
          );
        }
      case TransactionType.transfer:
        if (source.isCreditCard || counter!.isCreditCard) {
          throw const TransactionAccountMismatchException(
            'Transfers require two non-credit accounts',
          );
        }
      case TransactionType.cardStatementPayment:
        if (source.isCreditCard || !counter!.isCreditCard) {
          throw const TransactionAccountMismatchException(
            'Statement payments require a bank source and credit-card destination',
          );
        }
    }
  }
}

import '../../../core/ledger/balance_rules.dart';
import '../../../core/money/installment_plan.dart';
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

  Future<List<FinancialTransaction>> createInstallmentPlan({
    required FinancialTransaction purchase,
    required int installmentCount,
    required String groupId,
    required String Function(int installmentNumber) idForInstallment,
  }) async {
    if (purchase.type != TransactionType.cardPurchase) {
      throw ArgumentError('Only card purchases can be paid in installments');
    }
    if (installmentCount < 2 || installmentCount > 360) {
      throw RangeError.range(installmentCount, 2, 360, 'installmentCount');
    }
    await _validateAccounts(purchase);
    final amounts = InstallmentPlan.split(purchase.amount, installmentCount);
    final transactions = [
      for (var index = 0; index < installmentCount; index++)
        FinancialTransaction(
          id: idForInstallment(index + 1),
          description: purchase.description,
          type: TransactionType.cardPurchase,
          status: index == 0 ? purchase.status : TransactionStatus.previsto,
          amount: amounts[index],
          accountId: purchase.accountId,
          occurredAt: _addMonths(purchase.occurredAt, index),
          category: purchase.category,
          note: purchase.note,
          installmentGroupId: groupId,
          installmentNumber: index + 1,
          installmentCount: installmentCount,
          purchaseTotal: purchase.amount,
        ),
    ];
    for (final transaction in transactions) {
      if (await _repository.findById(transaction.id) != null) {
        throw TransactionAlreadyExistsException(transaction.id);
      }
    }
    await _repository.addAll(transactions);
    return List.unmodifiable(transactions);
  }

  DateTime _addMonths(DateTime date, int months) {
    final targetMonth = date.month - 1 + months;
    final year = date.year + targetMonth ~/ 12;
    final month = targetMonth % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, date.day.clamp(1, lastDay));
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/transaction_account_catalog.dart';
import '../application/transaction_service.dart';
import '../domain/financial_transaction.dart';
import '../domain/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  throw StateError('TransactionRepository was not configured');
});

final transactionAccountCatalogProvider = Provider<TransactionAccountCatalog>(
  (ref) => throw StateError('TransactionAccountCatalog was not configured'),
);

final transactionServiceProvider = Provider<TransactionService>(
  (ref) => TransactionService(
    ref.watch(transactionRepositoryProvider),
    ref.watch(transactionAccountCatalogProvider),
  ),
);

class TransactionsState {
  const TransactionsState({required this.items, required this.accounts});

  final List<FinancialTransaction> items;
  final List<TransactionAccountReference> accounts;
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsController, TransactionsState>(
      TransactionsController.new,
    );

class TransactionsController extends AsyncNotifier<TransactionsState> {
  TransactionService get _service => ref.read(transactionServiceProvider);

  @override
  Future<TransactionsState> build() => _load();

  Future<void> create(FinancialTransaction transaction) async {
    await _service.create(transaction);
    state = AsyncData(await _load());
  }

  Future<void> cancel(String id) async {
    await _service.cancel(id);
    state = AsyncData(await _load());
  }

  Future<TransactionsState> _load() async => TransactionsState(
    items: await _service.list(),
    accounts: await _service.listAccounts(),
  );
}

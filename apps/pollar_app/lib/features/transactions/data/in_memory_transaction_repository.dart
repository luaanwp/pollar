import '../domain/financial_transaction.dart';
import '../domain/transaction_repository.dart';

class InMemoryTransactionRepository implements TransactionRepository {
  InMemoryTransactionRepository({
    Iterable<FinancialTransaction> seed = const [],
  }) {
    for (final transaction in seed) {
      if (_transactions.containsKey(transaction.id)) {
        throw ArgumentError.value(
          transaction.id,
          'seed',
          'Duplicate transaction id',
        );
      }
      _transactions[transaction.id] = transaction;
    }
  }

  final Map<String, FinancialTransaction> _transactions = {};

  @override
  Future<void> add(FinancialTransaction transaction) async {
    if (_transactions.containsKey(transaction.id)) {
      throw StateError('Transaction already exists: ${transaction.id}');
    }
    _transactions[transaction.id] = transaction;
  }

  @override
  Future<List<FinancialTransaction>> findAll() async {
    final values = _transactions.values.toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List.unmodifiable(values);
  }

  @override
  Future<FinancialTransaction?> findById(String id) async => _transactions[id];

  @override
  Future<void> replace(FinancialTransaction transaction) async {
    if (!_transactions.containsKey(transaction.id)) {
      throw StateError('Transaction does not exist: ${transaction.id}');
    }
    _transactions[transaction.id] = transaction;
  }
}

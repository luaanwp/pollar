import 'financial_transaction.dart';

abstract interface class TransactionRepository {
  Future<List<FinancialTransaction>> findAll();

  Future<FinancialTransaction?> findById(String id);

  Future<void> add(FinancialTransaction transaction);

  Future<void> replace(FinancialTransaction transaction);
}

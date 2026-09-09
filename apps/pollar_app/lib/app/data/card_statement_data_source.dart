import '../../core/ledger/balance_rules.dart';
import '../../features/accounts/domain/account_repository.dart';
import '../../features/statements/application/statement_data_source.dart';
import '../../features/transactions/domain/financial_transaction.dart';
import '../../features/transactions/domain/transaction_repository.dart';

/// Composition adapter. The statements feature sees neutral records and never
/// imports accounts, transactions or Drift directly.
class CardStatementDataSource implements StatementDataSource {
  const CardStatementDataSource(this._accounts, this._transactions);

  final AccountRepository _accounts;
  final TransactionRepository _transactions;

  @override
  Future<StatementSourceData> load() async {
    final accounts = await _accounts.findAll();
    final transactions = await _transactions.findAll();
    return StatementSourceData(
      accounts: [
        for (final account in accounts)
          StatementAccountRecord(
            id: account.id,
            name: account.name,
            currency: account.currency,
            openingBalance: account.openingBalance,
            isCreditCard: account.isCreditCard,
            isArchived: account.isArchived,
            creditLimit: account.creditCardTerms?.creditLimit,
            closingDay: account.creditCardTerms?.closingDay,
            dueDay: account.creditCardTerms?.dueDay,
          ),
      ],
      transactions: [
        for (final transaction in transactions)
          StatementTransactionRecord(
            id: transaction.id,
            description: transaction.description,
            type: transaction.type,
            status: transaction.status,
            amount: transaction.amount,
            accountId: transaction.accountId,
            counterAccountId: transaction.counterAccountId,
            occurredAt: transaction.occurredAt,
            category: transaction.category,
            installmentNumber: transaction.installmentNumber,
            installmentCount: transaction.installmentCount,
            purchaseTotal: transaction.purchaseTotal,
            statementId: transaction.statementId,
          ),
      ],
    );
  }

  @override
  Future<void> recordPayment(StatementPaymentCommand command) =>
      _transactions.add(
        FinancialTransaction(
          id: command.id,
          description: 'Pagamento de fatura',
          type: TransactionType.cardStatementPayment,
          status: TransactionStatus.compensado,
          amount: command.amount,
          accountId: command.sourceAccountId,
          counterAccountId: command.cardId,
          occurredAt: command.occurredAt,
          category: 'Cartão',
          statementId: command.statementId,
        ),
      );
}

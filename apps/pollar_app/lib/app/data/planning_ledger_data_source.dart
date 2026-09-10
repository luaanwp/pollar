import '../../core/ledger/balance_rules.dart';
import '../../features/accounts/domain/account.dart';
import '../../features/accounts/domain/account_repository.dart';
import '../../features/planning/application/planning_ledger_source.dart';
import '../../features/transactions/domain/transaction_repository.dart';

class AppPlanningLedgerSource implements PlanningLedgerSource {
  const AppPlanningLedgerSource(this._accounts, this._transactions);

  final AccountRepository _accounts;
  final TransactionRepository _transactions;

  @override
  Future<List<PlanningAccountReference>> listAccounts() async =>
      (await _accounts.findAll())
          .where((account) => account.status == AccountStatus.active)
          .map(
            (account) => PlanningAccountReference(
              id: account.id,
              name: account.name,
              currency: account.currency,
              active: account.status == AccountStatus.active,
            ),
          )
          .toList(growable: false);

  @override
  Future<List<PlanningLedgerRecord>> listMovements() async =>
      (await _transactions.findAll())
          .map(
            (transaction) => PlanningLedgerRecord(
              occurredAt: transaction.occurredAt,
              amount: transaction.amount,
              kind: _kind(transaction.type),
              canceled: transaction.status == TransactionStatus.cancelado,
              category: transaction.category,
            ),
          )
          .toList(growable: false);

  PlanningMovementKind _kind(TransactionType type) => switch (type) {
    TransactionType.income => PlanningMovementKind.income,
    TransactionType.expense => PlanningMovementKind.expense,
    TransactionType.cardPurchase => PlanningMovementKind.cardPurchase,
    TransactionType.transfer ||
    TransactionType.cardStatementPayment => PlanningMovementKind.neutral,
  };
}

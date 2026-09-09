import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/data/dashboard_overview_data_source.dart';
import 'package:pollar_app/core/ledger/balance_rules.dart';
import 'package:pollar_app/core/money/currency.dart';
import 'package:pollar_app/core/money/money.dart';
import 'package:pollar_app/features/accounts/data/in_memory_account_repository.dart';
import 'package:pollar_app/features/accounts/domain/account.dart';
import 'package:pollar_app/features/overview/application/overview_data_source.dart';
import 'package:pollar_app/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:pollar_app/features/transactions/domain/financial_transaction.dart';

void main() {
  test(
    'maps both feature repositories into the overview read boundary',
    () async {
      final accounts = InMemoryAccountRepository(
        seed: [
          Account(
            id: 'checking',
            name: 'Conta principal',
            type: AccountType.checking,
            currency: Currency.brl,
            openingBalance: const Money(
              minorUnits: 10000,
              currency: Currency.brl,
            ),
          ),
        ],
      );
      final transactions = InMemoryTransactionRepository(
        seed: [
          FinancialTransaction(
            id: 'income',
            description: 'Receita',
            type: TransactionType.income,
            status: TransactionStatus.compensado,
            amount: const Money(minorUnits: 5000, currency: Currency.brl),
            accountId: 'checking',
            occurredAt: DateTime(2026, 9, 8),
          ),
        ],
      );

      final data = await DashboardOverviewDataSource(
        accounts,
        transactions,
      ).load();

      expect(data.accounts.single.id, 'checking');
      expect(data.accounts.single.kind, OverviewAccountKind.asset);
      expect(data.transactions.single.id, 'income');
      expect(data.transactions.single.type, TransactionType.income);
    },
  );
}

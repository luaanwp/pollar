import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/routing/app_router.dart';
import 'app/data/account_transaction_catalog.dart';
import 'app/data/dashboard_overview_data_source.dart';
import 'app/data/card_statement_data_source.dart';
import 'app/data/local_database_provider.dart';
import 'app/data/planning_ledger_data_source.dart';
import 'app/data/wealth_ledger_data_source.dart';
import 'app/theme/pollar_theme.dart';
import 'app/theme/theme_mode_provider.dart';
import 'features/accounts/data/default_accounts.dart';
import 'features/accounts/data/drift_account_repository.dart';
import 'features/accounts/presentation/accounts_controller.dart';
import 'features/overview/presentation/overview_controller.dart';
import 'features/planning/data/drift_planning_repository.dart';
import 'features/planning/presentation/planning_controller.dart';
import 'features/statements/presentation/statement_controller.dart';
import 'features/transactions/data/drift_transaction_repository.dart';
import 'features/transactions/presentation/transactions_controller.dart';
import 'features/wealth/data/drift_wealth_repository.dart';
import 'features/wealth/presentation/wealth_controller.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        accountRepositoryProvider.overrideWith((ref) {
          return DriftAccountRepository(
            ref.watch(localDatabaseProvider),
            initialAccounts: createDefaultAccounts(),
          );
        }),
        transactionRepositoryProvider.overrideWith(
          (ref) => DriftTransactionRepository(ref.watch(localDatabaseProvider)),
        ),
        transactionAccountCatalogProvider.overrideWith(
          (ref) =>
              AccountTransactionCatalog(ref.watch(accountRepositoryProvider)),
        ),
        overviewDataSourceProvider.overrideWith(
          (ref) => DashboardOverviewDataSource(
            ref.watch(accountRepositoryProvider),
            ref.watch(transactionRepositoryProvider),
          ),
        ),
        statementDataSourceProvider.overrideWith(
          (ref) => CardStatementDataSource(
            ref.watch(accountRepositoryProvider),
            ref.watch(transactionRepositoryProvider),
          ),
        ),
        planningRepositoryProvider.overrideWith(
          (ref) => DriftPlanningRepository(ref.watch(localDatabaseProvider)),
        ),
        planningLedgerSourceProvider.overrideWith(
          (ref) => AppPlanningLedgerSource(
            ref.watch(accountRepositoryProvider),
            ref.watch(transactionRepositoryProvider),
          ),
        ),
        wealthRepositoryProvider.overrideWith(
          (ref) => DriftWealthRepository(ref.watch(localDatabaseProvider)),
        ),
        wealthLedgerSourceProvider.overrideWith(
          (ref) => AppWealthLedgerSource(
            ref.watch(accountRepositoryProvider),
            ref.watch(transactionRepositoryProvider),
          ),
        ),
      ],
      child: const PollarApp(),
    ),
  );
}

class PollarApp extends ConsumerWidget {
  const PollarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pollar',
      debugShowCheckedModeBanner: false,
      theme: PollarTheme.light(),
      darkTheme: PollarTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}

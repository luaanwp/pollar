import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/auth/backend_configuration.dart';
import 'app/auth/auth_sync_session_access.dart';
import 'app/auth/secure_supabase_storage.dart';
import 'app/routing/app_router.dart';
import 'app/data/account_transaction_catalog.dart';
import 'app/data/dashboard_overview_data_source.dart';
import 'app/data/card_statement_data_source.dart';
import 'app/data/local_database_provider.dart';
import 'app/data/local_outbox_mutation_recorder.dart';
import 'app/data/local_sync_store.dart';
import 'app/data/local_backup_data_source.dart';
import 'app/data/planning_ledger_data_source.dart';
import 'app/data/report_ledger_data_source.dart';
import 'app/data/wealth_ledger_data_source.dart';
import 'app/theme/pollar_theme.dart';
import 'app/theme/theme_mode_provider.dart';
import 'features/accounts/data/default_accounts.dart';
import 'features/accounts/data/drift_account_repository.dart';
import 'features/accounts/presentation/accounts_controller.dart';
import 'features/auth/data/supabase_auth_gateway.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/data_management/data/local_backup_file_gateway.dart';
import 'features/data_management/presentation/data_management_controller.dart';
import 'features/overview/presentation/overview_controller.dart';
import 'features/planning/data/drift_planning_repository.dart';
import 'features/planning/presentation/planning_controller.dart';
import 'features/reports/data/local_report_exporter.dart';
import 'features/reports/presentation/reports_controller.dart';
import 'features/statements/presentation/statement_controller.dart';
import 'features/sync/data/supabase_sync_gateway.dart';
import 'features/sync/presentation/sync_controller.dart';
import 'features/transactions/data/drift_transaction_repository.dart';
import 'features/transactions/presentation/transactions_controller.dart';
import 'features/wealth/data/drift_wealth_repository.dart';
import 'features/wealth/presentation/wealth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseClient? supabase;
  if (BackendConfiguration.isConfigured) {
    await Supabase.initialize(
      url: BackendConfiguration.url,
      publishableKey: BackendConfiguration.publishableKey,
      authOptions: const FlutterAuthClientOptions(
        localStorage: SecureSupabaseStorage(),
      ),
    );
    supabase = Supabase.instance.client;
  }
  runApp(
    ProviderScope(
      overrides: [
        if (supabase case final client?) ...[
          authGatewayProvider.overrideWithValue(SupabaseAuthGateway(client)),
          syncRemoteGatewayProvider.overrideWithValue(
            SupabaseSyncGateway(client),
          ),
        ],
        syncLocalStoreProvider.overrideWith(
          (ref) => LocalSyncStore(ref.watch(localDatabaseProvider)),
        ),
        syncSessionAccessProvider.overrideWith(
          (ref) => AuthSyncSessionAccess(ref.watch(authGatewayProvider)),
        ),
        accountRepositoryProvider.overrideWith((ref) {
          return DriftAccountRepository(
            ref.watch(localDatabaseProvider),
            initialAccounts: createDefaultAccounts(),
            mutationRecorder: LocalOutboxMutationRecorder(
              ref.watch(localDatabaseProvider),
            ),
          );
        }),
        transactionRepositoryProvider.overrideWith(
          (ref) => DriftTransactionRepository(
            ref.watch(localDatabaseProvider),
            mutationRecorder: LocalOutboxMutationRecorder(
              ref.watch(localDatabaseProvider),
            ),
          ),
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
        reportDataSourceProvider.overrideWith(
          (ref) => ReportLedgerDataSource(
            ref.watch(accountRepositoryProvider),
            ref.watch(transactionRepositoryProvider),
          ),
        ),
        reportExporterProvider.overrideWithValue(const LocalReportExporter()),
        wealthRepositoryProvider.overrideWith(
          (ref) => DriftWealthRepository(ref.watch(localDatabaseProvider)),
        ),
        wealthLedgerSourceProvider.overrideWith(
          (ref) => AppWealthLedgerSource(
            ref.watch(accountRepositoryProvider),
            ref.watch(transactionRepositoryProvider),
          ),
        ),
        backupDataSourceProvider.overrideWith(
          (ref) => LocalBackupDataSource(
            ref.watch(localDatabaseProvider),
            ref.watch(accountRepositoryProvider),
            mutationRecorder: LocalOutboxMutationRecorder(
              ref.watch(localDatabaseProvider),
            ),
          ),
        ),
        backupFileGatewayProvider.overrideWithValue(
          const LocalBackupFileGateway(),
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

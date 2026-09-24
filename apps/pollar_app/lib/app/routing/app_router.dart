import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/account_form_screen.dart';
import '../../features/accounts/presentation/accounts_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/design_system/presentation/forms_catalog_screen.dart';
import '../../features/data_management/presentation/data_management_screen.dart';
import '../../features/overview/presentation/overview_screen.dart';
import '../../features/planning/presentation/planning_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/more_screen.dart';
import '../../features/statements/presentation/card_statement_screen.dart';
import '../../features/sync/presentation/sync_screen.dart';
import '../../features/sync/presentation/identity_mismatch_screen.dart';
import '../../features/sync/presentation/sync_controller.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/transactions/presentation/transaction_form_screen.dart';
import '../../features/wealth/presentation/wealth_screen.dart';
import 'app_shell.dart';

/// The app's [GoRouter]. A [StatefulShellRoute.indexedStack] keeps a separate
/// navigator per top-level destination so each tab preserves its own state.
///
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authGatewayProvider);
  final session =
      ref.watch(authSessionProvider).asData?.value ?? auth.currentSession;
  return GoRouter(
    initialLocation: '/overview',
    redirect: (context, state) async {
      if (!auth.isConfigured) return null;
      final onSignIn = state.matchedLocation == '/sign-in';
      final onMismatch = state.matchedLocation == '/account-mismatch';
      if (session == null && !onSignIn) return '/sign-in';
      if (session != null) {
        final matches = await ref
            .read(syncLocalStoreProvider)
            .bindIdentity(session.userId);
        if (!matches && !onMismatch) return '/account-mismatch';
        if (matches && (onSignIn || onMismatch)) return '/overview';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/account-mismatch',
        builder: (context, state) => const IdentityMismatchScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: '/design-system',
          builder: (context, state) => const FormsCatalogScreen(),
        ),
      if (kDebugMode)
        GoRoute(
          path: '/design-system/forms',
          redirect: (context, state) => '/design-system',
        ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/overview',
                builder: (context, state) => const OverviewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => TransactionFormScreen(
                      initialAccountId: state.uri.queryParameters['cardId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/accounts',
                builder: (context, state) => const AccountsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const AccountFormScreen(),
                  ),
                  GoRoute(
                    path: ':cardId/statement',
                    builder: (context, state) => CardStatementScreen(
                      cardId: state.pathParameters['cardId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planning',
                builder: (context, state) => const PlanningScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
                routes: [
                  GoRoute(
                    path: 'wealth',
                    builder: (context, state) => const WealthScreen(),
                  ),
                  GoRoute(
                    path: 'reports',
                    builder: (context, state) => const ReportsScreen(),
                  ),
                  GoRoute(
                    path: 'data',
                    builder: (context, state) => const DataManagementScreen(),
                  ),
                  GoRoute(
                    path: 'sync',
                    builder: (context, state) => const SyncScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        redirect: (context, state) => '/more/settings',
      ),
    ],
  );
});

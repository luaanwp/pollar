import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/account_form_screen.dart';
import '../../features/accounts/presentation/accounts_screen.dart';
import '../../features/design_system/presentation/forms_catalog_screen.dart';
import '../../features/overview/presentation/overview_screen.dart';
import '../../features/planning/presentation/planning_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/statements/presentation/card_statement_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/transactions/presentation/transaction_form_screen.dart';
import 'app_shell.dart';

/// The app's [GoRouter]. A [StatefulShellRoute.indexedStack] keeps a separate
/// navigator per top-level destination so each tab preserves its own state.
///
/// Auth is not wired yet: when the auth feature lands, add a `redirect` here
/// that sends unauthenticated users to `/sign-in` and guards the shell.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/overview',
    routes: [
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
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

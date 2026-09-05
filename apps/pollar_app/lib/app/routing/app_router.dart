import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/overview/presentation/overview_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
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

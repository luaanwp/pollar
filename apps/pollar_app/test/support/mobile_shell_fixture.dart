import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pollar_app/app/routing/app_shell.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';

GoRouter createMobileShellRouter() => GoRouter(
  initialLocation: '/overview',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        for (final d in appDestinations)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: d.path,
                builder: (context, state) => _DraftPage(label: d.label),
              ),
            ],
          ),
      ],
    ),
  ],
);

Widget mobileShellApp(GoRouter router, {bool dark = false}) => ProviderScope(
  child: MaterialApp.router(
    debugShowCheckedModeBanner: false,
    theme: dark ? PollarTheme.dark() : PollarTheme.light(),
    routerConfig: router,
  ),
);

class _DraftPage extends StatelessWidget {
  const _DraftPage({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(label, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      const TextField(decoration: InputDecoration(labelText: 'Rascunho local')),
    ],
  );
}

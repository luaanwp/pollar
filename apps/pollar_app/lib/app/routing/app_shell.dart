import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../privacy/privacy_mode_provider.dart';
import '../theme/pollar_theme.dart';
import '../theme/theme_mode_provider.dart';
import '../../shared/presentation/pollar_button.dart';

/// A top-level navigation destination in the app shell.
class AppDestination {
  const AppDestination({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final String path;
}

/// Destinations are added only when their route leads somewhere real.
const List<AppDestination> appDestinations = [
  AppDestination(
    label: 'Visão geral',
    icon: LucideIcons.layoutDashboard,
    path: '/overview',
  ),
  AppDestination(
    label: 'Transações',
    icon: LucideIcons.arrowLeftRight,
    path: '/transactions',
  ),
  AppDestination(
    label: 'Contas',
    icon: LucideIcons.walletCards,
    path: '/accounts',
  ),
  AppDestination(
    label: 'Preferências',
    icon: LucideIcons.settings,
    path: '/settings',
  ),
];

/// Adaptive shell wrapping the [StatefulNavigationShell]: a bottom navigation
/// bar on compact widths, a navigation rail on medium widths, and an extended
/// (labelled) rail on expanded widths — the cross-platform familiarity the
/// design system calls for. Each branch keeps its own navigation state.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) => navigationShell.goBranch(
    index,
    // Tapping the active destination returns it to its initial route.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < PollarBreakpoints.mediumMin;
    final index = navigationShell.currentIndex;

    final appBar = _ShellAppBar(title: appDestinations[index].label);
    final togglePrivacy = ref.read(privacyModeProvider.notifier).toggle;

    if (isCompact) {
      return _PrivacyShortcuts(
        onToggle: togglePrivacy,
        child: Scaffold(
          appBar: appBar,
          body: navigationShell,
          bottomNavigationBar: _BottomNav(
            selectedIndex: index,
            onSelected: _goBranch,
          ),
        ),
      );
    }

    final extended = width >= PollarBreakpoints.expandedMin;
    return _PrivacyShortcuts(
      onToggle: togglePrivacy,
      child: Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            _Rail(
              selectedIndex: index,
              onSelected: _goBranch,
              extended: extended,
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: context.pollar.border,
            ),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}

class _PrivacyShortcuts extends StatelessWidget {
  const _PrivacyShortcuts({required this.onToggle, required this.child});

  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): onToggle,
        const SingleActivator(LogicalKeyboardKey.keyP, meta: true): onToggle,
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

class _ShellAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _ShellAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollar = context.pollar;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final privacyHidden = ref.watch(privacyModeProvider);

    return AppBar(
      backgroundColor: pollar.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: Border(bottom: BorderSide(color: pollar.border)),
      titleSpacing: PollarSpacing.x6,
      title: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      actions: [
        PollarIconButton(
          label: privacyHidden ? 'Mostrar valores' : 'Ocultar valores',
          icon: privacyHidden ? LucideIcons.eyeOff : LucideIcons.eye,
          onPressed: ref.read(privacyModeProvider.notifier).toggle,
        ),
        PollarIconButton(
          label: isDark ? 'Tema claro' : 'Tema escuro',
          icon: isDark ? LucideIcons.sun : LucideIcons.moon,
          onPressed: () =>
              ref.read(themeModeProvider.notifier).toggle(isDark: isDark),
        ),
        const SizedBox(width: PollarSpacing.x2),
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.selectedIndex,
    required this.onSelected,
    required this.extended,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    return SizedBox(
      width: extended
          ? PollarSizes.sidebarExpanded
          : PollarSizes.sidebarCollapsed,
      child: NavigationRail(
        extended: extended,
        backgroundColor: pollar.canvas,
        indicatorColor: pollar.primarySoft,
        selectedIconTheme: IconThemeData(color: pollar.primary, size: 20),
        unselectedIconTheme: IconThemeData(
          color: pollar.textSecondary,
          size: 20,
        ),
        selectedLabelTextStyle: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: pollar.primary),
        unselectedLabelTextStyle: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: pollar.textSecondary),
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        groupAlignment: -1,
        labelType: extended
            ? NavigationRailLabelType.none
            : NavigationRailLabelType.all,
        leading: _RailHeader(extended: extended),
        destinations: [
          for (final d in appDestinations)
            NavigationRailDestination(
              icon: Icon(d.icon, size: 20),
              label: Text(d.label),
            ),
        ],
      ),
    );
  }
}

class _RailHeader extends StatelessWidget {
  const _RailHeader({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    // Placeholder ledger/flow mark (a rounded square), per the design system —
    // not a logo. The wordmark shows only when the rail is extended.
    final mark = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: pollar.primary,
        borderRadius: BorderRadius.circular(PollarRadii.small),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PollarSpacing.x5,
        vertical: PollarSpacing.x5,
      ),
      child: extended
          ? Row(
              children: [
                mark,
                const SizedBox(width: PollarSpacing.x3),
                Expanded(
                  child: Text(
                    'Pollar',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            )
          : mark,
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: pollar.border)),
      ),
      child: NavigationBar(
        backgroundColor: pollar.canvas,
        indicatorColor: pollar.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => Theme.of(context).textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? pollar.primary
                : pollar.textSecondary,
          ),
        ),
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: [
          for (final d in appDestinations)
            NavigationDestination(
              icon: Icon(d.icon, size: 24, color: pollar.textSecondary),
              selectedIcon: Icon(d.icon, size: 24, color: pollar.primary),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

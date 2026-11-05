import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../privacy/privacy_mode_provider.dart';
import '../theme/pollar_theme.dart';
import '../theme/theme_mode_provider.dart';
import '../../shared/presentation/pollar_button.dart';
import '../../shared/presentation/pollar_motion.dart';
import 'pollar_top_navigation.dart';
import 'app_destination.dart';
import 'pollar_more_menu.dart';
import '../../features/updates/presentation/app_update_widgets.dart';
import '../../features/updates/presentation/app_update_controller.dart';

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
    label: 'Planejamento',
    icon: LucideIcons.calendarRange,
    path: '/planning',
  ),
  AppDestination(label: 'Mais', icon: LucideIcons.ellipsis, path: '/more'),
];

/// Five stable branches: bottom navigation on phones, horizontal navigation
/// above the workspace on wider windows. Branches retain their own state.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _moreAnchor = GlobalKey();
  bool _moreOpen = false;

  StatefulNavigationShell get navigationShell => widget.navigationShell;

  Future<void> _openMore() async {
    if (_moreOpen) return;
    final box = _moreAnchor.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final overlay =
        Overlay.of(context, rootOverlay: true).context.findRenderObject()
            as RenderBox;
    final anchor = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
    Tooltip.dismissAllToolTips();
    setState(() => _moreOpen = true);
    final path = await showPollarMoreMenu(context, anchor);
    if (!mounted) return;
    setState(() => _moreOpen = false);
    if (path != null) context.push(path);
  }

  void _goBranch(int index) {
    if (index == 4) {
      _openMore();
      return;
    }
    navigationShell.goBranch(
      index,
      // Tapping the active destination returns it to its initial route.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < PollarBreakpoints.mediumMin;
    final index = navigationShell.currentIndex;

    // The compact transaction list has no separate body heading.
    final isPageHeading =
        isCompact && GoRouterState.of(context).uri.path == '/transactions';
    final title = appDestinations[index].label;
    final moreDetail =
        index == 4 && GoRouterState.of(context).uri.path.startsWith('/more/');
    var toolbarHeight = kToolbarHeight;
    if (isPageHeading) {
      final painter = TextPainter(
        text: TextSpan(
          text: title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: (width - 136).clamp(1, double.infinity));
      toolbarHeight = (painter.height + 16).clamp(
        kToolbarHeight,
        double.infinity,
      );
      painter.dispose();
    }
    final appBar = _ShellAppBar(
      title: title,
      isPageHeading: isPageHeading,
      height: toolbarHeight,
      onBack: moreDetail
          ? () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/more');
              }
            }
          : null,
    );
    final togglePrivacy = ref.read(privacyModeProvider.notifier).toggle;

    if (isCompact) {
      return _PrivacyShortcuts(
        onToggle: togglePrivacy,
        child: Scaffold(
          appBar: appBar,
          body: SafeArea(
            top: false,
            bottom: false,
            child: _UpdateContent(child: navigationShell),
          ),
          bottomNavigationBar: _BottomNav(
            selectedIndex: _moreOpen ? 4 : index,
            onSelected: _goBranch,
            moreAnchor: _moreAnchor,
          ),
        ),
      );
    }

    return _PrivacyShortcuts(
      onToggle: togglePrivacy,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              PollarTopNavigation(
                selectedIndex: _moreOpen ? 4 : index,
                onSelected: _goBranch,
                destinations: appDestinations,
                utilities: const _ShellUtilities(),
                moreAnchor: _moreAnchor,
              ),
              if (moreDetail)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16),
                    child: Tooltip(
                      message: 'Voltar',
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: appBar.onBack,
                        icon: const Icon(LucideIcons.arrowLeft, size: 20),
                        label: const Text('Voltar'),
                      ),
                    ),
                  ),
                ),
              Expanded(child: _UpdateContent(child: navigationShell)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateContent extends ConsumerWidget {
  const _UpdateContent({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(appUpdateProvider.select((state) => state.release)) == null ||
        View.of(context).viewInsets.bottom > 0) {
      return child;
    }
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight * .4),
            child: const SingleChildScrollView(
              child: AppUpdatePanel(noticeOnly: true),
            ),
          ),
          Expanded(child: child),
        ],
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
  const _ShellAppBar({
    required this.title,
    required this.isPageHeading,
    required this.height,
    this.onBack,
  });

  final String title;
  final bool isPageHeading;
  final double height;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollar = context.pollar;

    return AppBar(
      backgroundColor: pollar.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: Border(bottom: BorderSide(color: pollar.border)),
      toolbarHeight: height,
      titleSpacing: PollarSpacing.x4,
      title: Row(
        children: [
          if (onBack != null) ...[
            PollarIconButton(
              label: 'Voltar',
              icon: LucideIcons.arrowLeft,
              onPressed: onBack,
            ),
            const SizedBox(width: PollarSpacing.x2),
          ],
          if (isPageHeading)
            Expanded(
              child: Text(
                title,
                textScaler: MediaQuery.textScalerOf(context),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
        ],
      ),
      actions: const [_ShellUtilities()],
    );
  }
}

class _ShellUtilities extends ConsumerWidget {
  const _ShellUtilities();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final privacyHidden = ref.watch(privacyModeProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.selectedIndex,
    required this.onSelected,
    required this.moreAnchor,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final GlobalKey moreAnchor;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: pollar.border)),
      ),
      child: NavigationBar(
        animationDuration: PollarMotion.reduced(context)
            ? Duration.zero
            : PollarMotion.change,
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
              key: d.path == '/more'
                  ? moreAnchor
                  : ValueKey('navigation-${d.path}'),
              icon: Icon(d.icon, size: 24, color: pollar.textSecondary),
              selectedIcon: Icon(d.icon, size: 24, color: pollar.primary),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

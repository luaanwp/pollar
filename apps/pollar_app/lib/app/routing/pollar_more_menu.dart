// The menu leaves the current branch mounted until a destination is chosen.
// Its rectangular panel opens near Mais over a dimmed, softly blurred workspace.
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../shared/presentation/pollar_motion.dart';
import '../theme/pollar_theme.dart';

const moreMenuDestinations = [
  (
    label: 'Relatórios',
    icon: LucideIcons.chartNoAxesCombined,
    path: '/more/reports',
  ),
  (label: 'Patrimônio', icon: LucideIcons.scale, path: '/more/wealth'),
  (label: 'Sincronização', icon: LucideIcons.cloudCog, path: '/more/sync'),
  (
    label: 'Dados e backup',
    icon: LucideIcons.databaseBackup,
    path: '/more/data',
  ),
  (label: 'Preferências', icon: LucideIcons.settings, path: '/more/settings'),
];

Future<String?> showPollarMoreMenu(BuildContext context, Rect anchor) {
  final reduced = PollarMotion.reduced(context);
  final openingSize = MediaQuery.sizeOf(context);
  final openingTextScale = MediaQuery.textScalerOf(context).scale(14);
  var dismissalQueued = false;
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar menu Mais',
    barrierColor: Colors.transparent,
    transitionDuration: reduced ? Duration.zero : PollarMotion.change,
    pageBuilder: (context, animation, secondaryAnimation) {
      final media = MediaQuery.of(context);
      // A changed layout invalidates the anchor and its clear backdrop cutout.
      if (!dismissalQueued &&
          (media.size != openingSize ||
              media.textScaler.scale(14) != openingTextScale)) {
        dismissalQueued = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted && ModalRoute.of(context)?.isCurrent == true) {
            Navigator.of(context).pop();
          }
        });
      }
      final padding = media.viewPadding.copyWith(
        bottom: math.max(media.viewPadding.bottom, media.viewInsets.bottom),
      );
      final panel = Material(
        key: const Key('more-menu-panel'),
        color: context.pollar.canvas,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PollarRadii.small),
          side: BorderSide(color: context.pollar.borderStrong),
        ),
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: 'Mais',
          explicitChildNodes: true,
          child: FocusTraversalGroup(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(PollarSpacing.x2),
              children: [
                for (var i = 0; i < moreMenuDestinations.length; i++)
                  TextButton(
                    autofocus: i == 0,
                    key: ValueKey('more-menu-${moreMenuDestinations[i].path}'),
                    onPressed: () =>
                        Navigator.of(context).pop(moreMenuDestinations[i].path),
                    style:
                        TextButton.styleFrom(
                          foregroundColor: context.pollar.textPrimary,
                          alignment: AlignmentDirectional.centerStart,
                          minimumSize: const Size(48, 52),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              PollarRadii.small,
                            ),
                          ),
                        ).copyWith(
                          side: WidgetStateProperty.resolveWith(
                            (states) => BorderSide(
                              color: states.contains(WidgetState.focused)
                                  ? context.pollar.info
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                    child: Row(
                      children: [
                        Icon(
                          moreMenuDestinations[i].icon,
                          size: 20,
                          color: context.pollar.primary,
                        ),
                        const SizedBox(width: PollarSpacing.x3),
                        Expanded(child: Text(moreMenuDestinations[i].label)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(context).pop(),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
              FocusManager.instance.primaryFocus?.nextFocus(),
          const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
              FocusManager.instance.primaryFocus?.previousFocus(),
        },
        child: FocusScope(
          autofocus: true,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipPath(
                    key: const Key('more-menu-backdrop-clip'),
                    clipper: _MoreBackdropClipper(anchor: anchor),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: ColoredBox(
                        key: const Key('more-menu-backdrop'),
                        color: Colors.black.withValues(alpha: .42),
                      ),
                    ),
                  ),
                ),
              ),
              CustomSingleChildLayout(
                delegate: _MoreMenuLayout(anchor: anchor, padding: padding),
                child: reduced
                    ? panel
                    : SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: Offset(
                                0,
                                anchor.center.dy > media.size.height / 2
                                    ? .025
                                    : -.025,
                              ),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: panel,
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Only the workspace is blurred/dimmed; Mais stays sharp and fully visible.
class _MoreBackdropClipper extends CustomClipper<Path> {
  const _MoreBackdropClipper({required this.anchor});
  final Rect anchor;

  @override
  Path getClip(Size size) {
    final bounds = Offset.zero & size;
    final clearAnchor = anchor.inflate(4).intersect(bounds);
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(bounds);
    if (!clearAnchor.isEmpty) {
      path.addRRect(
        RRect.fromRectAndRadius(
          clearAnchor,
          const Radius.circular(PollarRadii.medium),
        ),
      );
    }
    return path;
  }

  @override
  bool shouldReclip(_MoreBackdropClipper oldClipper) =>
      anchor != oldClipper.anchor;
}

class _MoreMenuLayout extends SingleChildLayoutDelegate {
  const _MoreMenuLayout({required this.anchor, required this.padding});
  final Rect anchor;
  final EdgeInsets padding;
  static const gap = 8.0;
  static const gutter = 16.0;

  double _below(Size size) =>
      math.max(0, size.height - padding.bottom - gutter - anchor.bottom - gap);
  double get _above => math.max(0, anchor.top - gap - padding.top - gutter);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final size = constraints.biggest;
    final width = math.min(320.0, size.width - padding.horizontal - gutter * 2);
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      maxHeight: math.min(
        math.max(_above, _below(size)),
        math.max(0, size.height - padding.vertical - gutter * 2),
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = (anchor.right - childSize.width).clamp(
      padding.left + gutter,
      math.max(
        padding.left + gutter,
        size.width - padding.right - gutter - childSize.width,
      ),
    );
    final top = childSize.height <= _below(size)
        ? anchor.bottom + gap
        : anchor.top - gap - childSize.height;
    return Offset(
      left.toDouble(),
      top
          .clamp(
            padding.top + gutter,
            math.max(
              padding.top + gutter,
              size.height - padding.bottom - gutter - childSize.height,
            ),
          )
          .toDouble(),
    );
  }

  @override
  bool shouldRelayout(_MoreMenuLayout oldDelegate) =>
      anchor != oldDelegate.anchor || padding != oldDelegate.padding;
}

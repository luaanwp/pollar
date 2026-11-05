// THESIS: five visible destinations above a full-width financial workspace.
// OWN-WORLD: Pollar's solid canvas, teal mark, Inter and Lucide; no side panel.
// STORY: identify the destination, switch sections, then read the ledger.
// FIRST VIEWPORT: brand left, labelled navigation centre, utilities right.
// FORM: one horizontal row when it fits; a separate menu row otherwise.
// FINISH: review the desktop/mobile renders and record the implemented rules.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/presentation/pollar_brand.dart';
import '../../shared/presentation/pollar_motion.dart';
import '../theme/pollar_theme.dart';
import 'app_destination.dart';

/// A labelled route menu, measured using the current font and text scaler.
/// It never reduces labels to icons or takes width away from the workspace.
class PollarTopNavigation extends StatefulWidget {
  const PollarTopNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.utilities,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget utilities;

  @override
  State<PollarTopNavigation> createState() => _PollarTopNavigationState();
}

class _PollarTopNavigationState extends State<PollarTopNavigation> {
  final _scroll = ScrollController();
  double? _availableWidth;
  late final _targets = List.generate(
    widget.destinations.length,
    (_) => GlobalKey(),
  );

  void _revealSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = _targets[widget.selectedIndex].currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          alignment: .5,
          duration: PollarMotion.reduced(context)
              ? Duration.zero
              : PollarMotion.change,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant PollarTopNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) _revealSelected();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.pollar;
    final style = Theme.of(context).textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.w600);
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    Size measure(String label, TextStyle textStyle) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final size = painter.size;
      painter.dispose();
      return size;
    }

    final labels = [
      for (final d in widget.destinations) measure(d.label, style),
    ];
    // 20dp icon, 8dp gap, 16dp padding on each side.
    final widths = [for (final size in labels) size.width.ceilToDouble() + 60];
    final menuWidth = widths.fold<double>(0, (sum, width) => sum + width);
    final menuHeight = math.max(56.0, labels.first.height.ceilToDouble() + 32);
    final brandWidth =
        measure(
          'Pollar',
          Theme.of(context).textTheme.headlineSmall!
              .copyWith(fontWeight: FontWeight.w600),
        ).width +
        40;
    final headerHeight = math.max(72.0, scaler.scale(28) + 32);
    final selectedStart = widths
        .take(widget.selectedIndex)
        .fold<double>(0, (sum, width) => sum + width);

    return Material(
      color: palette.canvas,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.border)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_availableWidth != constraints.maxWidth) {
              _availableWidth = constraints.maxWidth;
              _revealSelected();
            }
            // Leave 24dp gutters and 32dp between the three meaningful groups.
            final inline =
                constraints.maxWidth >= brandWidth + menuWidth + 104 + 112;
            final menu = SizedBox(
              height: menuHeight,
              child: Scrollbar(
                controller: _scroll,
                thumbVisibility:
                    !inline && menuWidth > constraints.maxWidth - 48,
                child: SingleChildScrollView(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: menuWidth,
                    child: Stack(
                      children: [
                        AnimatedPositionedDirectional(
                          duration: PollarMotion.reduced(context)
                              ? Duration.zero
                              : PollarMotion.change,
                          curve: Curves.easeOutCubic,
                          start: selectedStart + 16,
                          bottom: 4,
                          width: widths[widget.selectedIndex] - 32,
                          height: 2,
                          child: ColoredBox(color: palette.primary),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < widget.destinations.length; i++)
                              SizedBox(
                                width: widths[i],
                                height: menuHeight,
                                child: Semantics(
                                  selected: i == widget.selectedIndex,
                                  child: Tooltip(
                                    message: widget.destinations[i].label,
                                    child: TextButton(
                                      key: _targets[i],
                                      onPressed: () => widget.onSelected(i),
                                      style: ButtonStyle(
                                        padding: const WidgetStatePropertyAll(
                                          EdgeInsets.symmetric(horizontal: 16),
                                        ),
                                        shape: WidgetStatePropertyAll(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        side: WidgetStateProperty.resolveWith(
                                          (states) => BorderSide(
                                            color:
                                                states.contains(
                                                  WidgetState.focused,
                                                )
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        foregroundColor: WidgetStatePropertyAll(
                                          i == widget.selectedIndex
                                              ? palette.primary
                                              : palette.textSecondary,
                                        ),
                                        textStyle: WidgetStatePropertyAll(
                                          style,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            widget.destinations[i].icon,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            widget.destinations[i].label,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: Row(
                      children: [
                        SizedBox(width: brandWidth, child: const PollarBrand()),
                        const Spacer(),
                        if (inline) ...[menu, const Spacer()],
                        widget.utilities,
                      ],
                    ),
                  ),
                  if (!inline)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: menu,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

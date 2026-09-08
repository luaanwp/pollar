import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';

enum PollarCardPadding { none, small, medium, large }

/// Bordered grouping surface. Interactive cards expose button semantics and a
/// restrained hover elevation on pointer devices.
class PollarCard extends StatefulWidget {
  const PollarCard({
    super.key,
    required this.child,
    this.padding = PollarCardPadding.large,
    this.alt = false,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final PollarCardPadding padding;
  final bool alt;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<PollarCard> createState() => _PollarCardState();
}

class _PollarCardState extends State<PollarCard> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.pollar;
    final interactive = widget.onTap != null;
    final padding = switch (widget.padding) {
      PollarCardPadding.none => EdgeInsets.zero,
      PollarCardPadding.small => const EdgeInsets.all(PollarSpacing.x3),
      PollarCardPadding.medium => const EdgeInsets.all(PollarSpacing.x4),
      PollarCardPadding.large => const EdgeInsets.all(PollarSpacing.x5),
    };

    return Semantics(
      label: widget.semanticLabel,
      button: interactive,
      child: MouseRegion(
        onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
        onExit: interactive ? (_) => setState(() => _hovered = false) : null,
        child: Card(
          color: widget.alt ? colors.surfaceAlt : colors.canvas,
          elevation: interactive && _hovered ? 1 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PollarRadii.large),
            side: BorderSide(
              color: interactive && _hovered
                  ? colors.borderStrong
                  : colors.border,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: colors.surfaceAlt,
            focusColor: colors.primarySoft,
            child: Padding(padding: padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';

enum PollarCardPadding { none, small, medium, large }

/// Outlined is the legacy default; other roles are migrated explicitly.
enum PollarCardVariant { outlined, flat, financial }

/// Bordered grouping surface. Interactive cards expose button semantics and a
/// restrained hover elevation on pointer devices.
class PollarCard extends StatefulWidget {
  const PollarCard({
    super.key,
    required this.child,
    this.padding = PollarCardPadding.large,
    this.alt = false,
    this.variant = PollarCardVariant.outlined,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final PollarCardPadding padding;
  final bool alt;
  final PollarCardVariant variant;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<PollarCard> createState() => _PollarCardState();
}

class _PollarCardState extends State<PollarCard> {
  var _hovered = false;
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.pollar;
    final interactive = widget.onTap != null;
    final bordered =
        interactive || widget.variant == PollarCardVariant.outlined;
    final background = widget.variant == PollarCardVariant.financial
        ? colors.financialSurface
        : widget.alt
        ? colors.surfaceAlt
        : colors.canvas;
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
          color: background,
          elevation: interactive && _hovered ? 1 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PollarRadii.large),
            side: _focused && interactive
                ? BorderSide(color: colors.info, width: 2)
                : bordered
                ? BorderSide(
                    color: interactive && _hovered
                        ? colors.borderStrong
                        : colors.border,
                  )
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            canRequestFocus: interactive,
            onFocusChange: (focused) => setState(() => _focused = focused),
            hoverColor: colors.surfaceAlt,
            focusColor: colors.primarySoft,
            child: Padding(padding: padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

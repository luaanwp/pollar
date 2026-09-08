import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/pollar_theme.dart';

enum PollarButtonVariant { primary, secondary, ghost, danger }

enum PollarControlSize { compact, standard, prominent }

/// Standard labeled action. Loading is announced and disables activation.
class PollarButton extends StatelessWidget {
  const PollarButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PollarButtonVariant.primary,
    this.size = PollarControlSize.standard,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PollarButtonVariant variant;
  final PollarControlSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool loading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.pollar;
    final disabled = onPressed == null || loading;
    final compactLayout =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    final requestedHeight = switch (size) {
      PollarControlSize.compact => PollarSizes.buttonCompact,
      PollarControlSize.standard => PollarSizes.buttonStandard,
      PollarControlSize.prominent => PollarSizes.buttonProminent,
    };
    final height = compactLayout
        ? math.max(requestedHeight, PollarSizes.touchTargetMin)
        : requestedHeight;
    final horizontalPadding = switch (size) {
      PollarControlSize.compact => PollarSpacing.x3,
      PollarControlSize.standard => PollarSpacing.x4,
      PollarControlSize.prominent => PollarSpacing.x5,
    };
    final iconSize = size == PollarControlSize.compact ? 16.0 : 20.0;
    final foreground = _foreground(colors, Theme.of(context).colorScheme);
    final background = _background(colors);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          if (MediaQuery.disableAnimationsOf(context))
            Icon(LucideIcons.loaderCircle, size: iconSize)
          else
            SizedBox.square(
              dimension: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
              ),
            ),
          const SizedBox(width: PollarSpacing.x2),
        ] else if (leadingIcon case final icon?) ...[
          Icon(icon, size: iconSize),
          const SizedBox(width: PollarSpacing.x2),
        ],
        Flexible(child: Text(label, maxLines: 2, textAlign: TextAlign.center)),
        if (!loading && trailingIcon != null) ...[
          const SizedBox(width: PollarSpacing.x2),
          Icon(trailingIcon, size: iconSize),
        ],
      ],
    );

    return Semantics(
      label: loading ? '$label, carregando' : label,
      button: true,
      enabled: !disabled,
      excludeSemantics: true,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: height,
        child: TextButton(
          onPressed: disabled ? null : onPressed,
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: horizontalPadding),
            ),
            elevation: const WidgetStatePropertyAll(0),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PollarRadii.medium),
              ),
            ),
            textStyle: WidgetStatePropertyAll(
              Theme.of(context).textTheme.labelLarge,
            ),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return foreground.withValues(alpha: 0.55);
              }
              if (states.contains(WidgetState.hovered) &&
                  variant != PollarButtonVariant.primary &&
                  variant != PollarButtonVariant.danger) {
                return colors.textPrimary;
              }
              return foreground;
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return background.withValues(alpha: 0.55);
              }
              if (states.contains(WidgetState.hovered)) {
                if (variant == PollarButtonVariant.primary) {
                  return colors.primaryHover;
                }
                if (variant == PollarButtonVariant.secondary ||
                    variant == PollarButtonVariant.ghost) {
                  return colors.surfaceAlt;
                }
              }
              return background;
            }),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.focused)) {
                return BorderSide(color: colors.info, width: 2);
              }
              return BorderSide(color: _border(colors));
            }),
          ),
          child: content,
        ),
      ),
    );
  }

  Color _foreground(PollarColors colors, ColorScheme scheme) =>
      switch (variant) {
        PollarButtonVariant.primary => scheme.onPrimary,
        PollarButtonVariant.secondary => colors.textPrimary,
        PollarButtonVariant.ghost => colors.textSecondary,
        PollarButtonVariant.danger => scheme.onError,
      };

  Color _background(PollarColors colors) => switch (variant) {
    PollarButtonVariant.primary => colors.primary,
    PollarButtonVariant.secondary => colors.canvas,
    PollarButtonVariant.ghost => Colors.transparent,
    PollarButtonVariant.danger => colors.danger,
  };

  Color _border(PollarColors colors) => switch (variant) {
    PollarButtonVariant.primary => colors.primary,
    PollarButtonVariant.secondary => colors.borderStrong,
    PollarButtonVariant.ghost => Colors.transparent,
    PollarButtonVariant.danger => colors.danger,
  };
}

/// Square icon action. [label] always supplies its tooltip and semantics name.
class PollarIconButton extends StatelessWidget {
  const PollarIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = PollarControlSize.standard,
    this.outlined = false,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final PollarControlSize size;
  final bool outlined;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.pollar;
    final compactLayout =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    final requested = switch (size) {
      PollarControlSize.compact => PollarSizes.buttonCompact,
      PollarControlSize.standard => PollarSizes.buttonStandard,
      PollarControlSize.prominent => PollarSizes.buttonProminent,
    };
    final box = compactLayout
        ? math.max(requested, PollarSizes.touchTargetMin)
        : requested;

    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      isSelected: selected,
      selectedIcon: Icon(
        icon,
        size: size == PollarControlSize.compact ? 16 : 20,
      ),
      icon: Icon(icon, size: size == PollarControlSize.compact ? 16 : 20),
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll(Size.square(box)),
        minimumSize: WidgetStatePropertyAll(Size.square(box)),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => selected ? colors.primary : colors.textSecondary,
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (selected) return colors.primarySoft;
          if (states.contains(WidgetState.hovered)) return colors.surfaceAlt;
          return outlined ? colors.canvas : Colors.transparent;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: colors.info, width: 2);
          }
          return BorderSide(
            color: outlined ? colors.borderStrong : Colors.transparent,
          );
        }),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PollarRadii.medium),
          ),
        ),
      ),
    );
  }
}

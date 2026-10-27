import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';

/// Shared solid identity for registered credit cards and their statement.
/// Only this subtree changes its money, privacy-mask and control foregrounds.
class PollarCreditSurface extends StatelessWidget {
  const PollarCreditSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(PollarRadii.large),
    ),
  });
  final Widget child;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = context.pollar;
    final theme = Theme.of(context);
    final foreground = palette.creditForeground;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.creditSurface,
        borderRadius: borderRadius,
      ),
      child: Theme(
        data: theme.copyWith(
          iconTheme: theme.iconTheme.copyWith(color: foreground),
          textTheme: theme.textTheme.apply(
            bodyColor: foreground,
            displayColor: foreground,
          ),
          extensions: [
            ...theme.extensions.values.where((item) => item is! PollarColors),
            palette.copyWith(
              textPrimary: foreground,
              textSecondary: palette.creditSecondary,
              success: foreground,
              danger: foreground,
              info: foreground,
              surfaceAlt: palette.creditHover,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(PollarSpacing.x5),
          child: child,
        ),
      ),
    );
  }
}

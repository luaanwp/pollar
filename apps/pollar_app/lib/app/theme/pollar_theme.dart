import 'package:flutter/material.dart';

import 'pollar_colors.dart';
import 'pollar_dimens.dart';
import 'pollar_typography.dart';

export 'pollar_colors.dart';
export 'pollar_dimens.dart';
export 'pollar_typography.dart';

/// Builds the Pollar [ThemeData] for both brightnesses from the design tokens.
///
/// The Material [ColorScheme] carries the roles Material widgets read; the full
/// semantic palette lives in the [PollarColors] extension. Read brand colors
/// through `context.pollar` — never hardcode a hex in a widget.
abstract final class PollarTheme {
  static ThemeData light() => _build(PollarColors.light, Brightness.light);
  static ThemeData dark() => _build(PollarColors.dark, Brightness.dark);

  static ThemeData _build(PollarColors c, Brightness brightness) {
    final onPrimary = brightness == Brightness.light
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF06231D);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: onPrimary,
      primaryContainer: c.primarySoft,
      onPrimaryContainer: c.primary,
      secondary: c.info,
      onSecondary: onPrimary,
      surface: c.canvas,
      onSurface: c.textPrimary,
      surfaceContainerLowest: c.canvas,
      surfaceContainerLow: c.background,
      surfaceContainer: c.surfaceAlt,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      outlineVariant: c.borderStrong,
      error: c.danger,
      onError: onPrimary,
    );

    final textTheme = PollarTypography.textTheme(c.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.canvas,
      dividerColor: c.border,
      fontFamily: PollarTypography.fontFamily,
      textTheme: textTheme,
      extensions: [c],
      // Cards: canvas fill, 1px border, 14px radius, no shadow at rest.
      cardTheme: CardThemeData(
        color: c.canvas,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PollarRadii.large),
          side: BorderSide(color: c.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      // Focus is a 2px info ring at 2px offset, always visible.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.canvas,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PollarRadii.medium),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PollarRadii.medium),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PollarRadii.medium),
          borderSide: BorderSide(color: c.info, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(0, PollarSizes.buttonStandard),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PollarRadii.medium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      splashFactory: NoSplash.splashFactory,
    );
  }
}

/// Ergonomic access to the semantic Pollar palette from any [BuildContext].
///
/// Usage: `context.pollar.danger`, `context.pollar.textSecondary`.
extension PollarThemeContext on BuildContext {
  PollarColors get pollar => Theme.of(this).extension<PollarColors>()!;
}

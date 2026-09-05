import 'package:flutter/material.dart';

/// Inter type scale from `pollar_design_tokens.json`.
///
/// Hierarchy is carried by weight, not size. Only four Inter weights are
/// bundled (400/500/600/700), so the token weight `650` (display/h2/amountHero)
/// maps to the nearest available `w600` — noted where it applies. Sizes here
/// are the **desktop** values; compact screens scale down via [scaleForMobile].
abstract final class PollarTypography {
  static const String fontFamily = 'Inter';

  /// Tabular figures — non-negotiable for money, table dates, percentages and
  /// installment counts, so columns of digits align.
  static const List<FontFeature> _tnum = [FontFeature.tabularFigures()];

  /// Returns [style] with tabular figures enabled. Apply to every rendered
  /// figure, never to running prose.
  static TextStyle tabular(TextStyle style) =>
      style.copyWith(fontFeatures: _tnum);

  /// Hero amount (dashboard total). Token `amountHero` 34/650 → w600.
  static const TextStyle amountHero = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    height: 1.15,
    fontWeight: FontWeight.w600,
    fontFeatures: _tnum,
  );

  /// Inline amount in rows/cards. Token `amountStandard` 16/600.
  static const TextStyle amountStandard = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
    fontFeatures: _tnum,
  );

  /// 11px uppercase eyebrow for table headers and sidebar dividers.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.06 * 11,
  );

  /// Desktop [TextTheme] tinted to [color] (the theme's primary text color).
  static TextTheme textTheme(Color color) {
    TextStyle s(
      double size,
      FontWeight weight,
      double lineHeight, {
      double tracking = 0,
    }) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: lineHeight,
      fontWeight: weight,
      letterSpacing: tracking,
      color: color,
    );

    return TextTheme(
      // display 32/700, slight negative tracking.
      displayLarge: s(32, FontWeight.w700, 1.2, tracking: -0.02 * 32),
      // h1 26/700.
      headlineLarge: s(26, FontWeight.w700, 1.25, tracking: -0.015 * 26),
      // h2 22/650 → w600.
      headlineMedium: s(22, FontWeight.w600, 1.3),
      // h3 18/600.
      headlineSmall: s(18, FontWeight.w600, 1.35),
      // label 13/600 (buttons, field labels).
      titleMedium: s(13, FontWeight.w600, 1.35),
      labelLarge: s(13, FontWeight.w600, 1.35),
      // bodyLarge 16/400.
      bodyLarge: s(16, FontWeight.w400, 1.5),
      // body 14/400.
      bodyMedium: s(14, FontWeight.w400, 1.5),
      // caption 12/500.
      bodySmall: s(12, FontWeight.w500, 1.4),
    );
  }

  /// Compact-screen size deltas (token mobile values): display 32→28, h1 26→24,
  /// h2 22→20, amountHero 34→30. Everything else is identical across sizes.
  static TextTheme scaleForMobile(TextTheme base) => base.copyWith(
    displayLarge: base.displayLarge?.copyWith(fontSize: 28),
    headlineLarge: base.headlineLarge?.copyWith(fontSize: 24),
    headlineMedium: base.headlineMedium?.copyWith(fontSize: 20),
  );
}

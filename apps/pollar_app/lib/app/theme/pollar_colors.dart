import 'package:flutter/material.dart';

/// Semantic Pollar colors that Material's [ColorScheme] does not model
/// directly (alt surfaces, borders, muted text tiers, financial semantics).
///
/// Values come verbatim from `pollar_design_tokens.json`. Never hardcode a hex
/// in a widget — read it from `Theme.of(context).extension<PollarColors>()!`
/// (or the `context.pollarColors` extension in `pollar_theme.dart`).
@immutable
class PollarColors extends ThemeExtension<PollarColors> {
  const PollarColors({
    required this.primary,
    required this.primaryHover,
    required this.primarySoft,
    required this.canvas,
    required this.background,
    required this.surfaceAlt,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.successSoft,
    required this.danger,
    required this.dangerSoft,
    required this.warning,
    required this.warningSoft,
    required this.info,
    required this.infoSoft,
  });

  /// One brand hue: deep desaturated teal (light) / lighter teal (dark).
  final Color primary;
  final Color primaryHover;

  /// Pale tint used for selection surfaces (never color alone for state).
  final Color primarySoft;

  /// Card fill. Max two background values per screen: [canvas] + [background].
  final Color canvas;

  /// Page ground behind cards.
  final Color background;

  /// Hover fill for rows, ghost/secondary buttons.
  final Color surfaceAlt;

  /// 1px structural border at rest.
  final Color border;

  /// Border on hover / stronger separation.
  final Color borderStrong;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Four semantic colors only — icon+text pair them, never color alone.
  final Color success;
  final Color successSoft;
  final Color danger;
  final Color dangerSoft;
  final Color warning;
  final Color warningSoft;
  final Color info;
  final Color infoSoft;

  static const PollarColors light = PollarColors(
    primary: Color(0xFF087F6B),
    primaryHover: Color(0xFF066858),
    primarySoft: Color(0xFFEAF8F4),
    canvas: Color(0xFFFFFFFF),
    background: Color(0xFFF7F9F8),
    surfaceAlt: Color(0xFFF1F4F3),
    border: Color(0xFFD8DEDC),
    borderStrong: Color(0xFFB9C3C0),
    textPrimary: Color(0xFF13201D),
    textSecondary: Color(0xFF52615D),
    textMuted: Color(0xFF66736F),
    success: Color(0xFF0F7444),
    successSoft: Color(0xFFE8F5EE),
    danger: Color(0xFFC53B3B),
    dangerSoft: Color(0xFFFBECEC),
    warning: Color(0xFF8B5707),
    warningSoft: Color(0xFFFBF1E3),
    info: Color(0xFF2667C9),
    infoSoft: Color(0xFFEAF0FB),
  );

  static const PollarColors dark = PollarColors(
    primary: Color(0xFF5ED3B8),
    primaryHover: Color(0xFF80DEC9),
    primarySoft: Color(0xFF153B34),
    canvas: Color(0xFF121A18),
    background: Color(0xFF0C1211),
    surfaceAlt: Color(0xFF1A2522),
    border: Color(0xFF2D3B37),
    borderStrong: Color(0xFF40514C),
    textPrimary: Color(0xFFEEF4F2),
    textSecondary: Color(0xFFB5C3BF),
    textMuted: Color(0xFF8B9B96),
    success: Color(0xFF55CF91),
    successSoft: Color(0xFF12301F),
    danger: Color(0xFFFF8585),
    dangerSoft: Color(0xFF3A1E1E),
    warning: Color(0xFFF3B85D),
    warningSoft: Color(0xFF38290F),
    info: Color(0xFF80AEFF),
    infoSoft: Color(0xFF16233A),
  );

  @override
  PollarColors copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primarySoft,
    Color? canvas,
    Color? background,
    Color? surfaceAlt,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? successSoft,
    Color? danger,
    Color? dangerSoft,
    Color? warning,
    Color? warningSoft,
    Color? info,
    Color? infoSoft,
  }) {
    return PollarColors(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primarySoft: primarySoft ?? this.primarySoft,
      canvas: canvas ?? this.canvas,
      background: background ?? this.background,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
    );
  }

  @override
  PollarColors lerp(covariant ThemeExtension<PollarColors>? other, double t) {
    if (other is! PollarColors) return this;
    return PollarColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      background: Color.lerp(background, other.background, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
    );
  }
}

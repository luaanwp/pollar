/// Non-color design tokens from `pollar_design_tokens.json`.
///
/// These are fixed across themes, so they are plain constants rather than a
/// [ThemeExtension]. Base unit 4, rhythm 8.
library;

/// Spacing scale (px). Named by the token key: `space.4` == 16px.
abstract final class PollarSpacing {
  static const double x0 = 0;
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
  static const double x16 = 64;
  static const double x20 = 80;
}

/// Corner radii (px). 6 chips, 10 inputs/buttons/tables, 14 cards/dialogs,
/// 999 badges only — a pill-shaped button is off-brand.
abstract final class PollarRadii {
  static const double small = 6;
  static const double medium = 10;
  static const double large = 14;
  static const double pill = 999;
}

/// Motion durations (ms as [Duration]). 100 fast feedback, 180 state change,
/// 240 panels/dialogs/sheets. Financial digits never animate.
abstract final class PollarDurations {
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration standard = Duration(milliseconds: 180);
  static const Duration panel = Duration(milliseconds: 240);
}

/// Fixed component sizes (px).
abstract final class PollarSizes {
  static const double buttonCompact = 32;
  static const double buttonStandard = 40;
  static const double buttonProminent = 48;
  static const double touchTargetMin = 44;
  static const double sidebarExpanded = 256;
  static const double sidebarCollapsed = 72;
  static const double contextPanel = 360;
  static const double contentMax = 1600;
  static const double dashboardMax = 1280;
}

/// Responsive breakpoints (px, min-width unless noted).
abstract final class PollarBreakpoints {
  static const double compactMax = 599;
  static const double mediumMin = 600;
  static const double expandedMin = 1024;
  static const double wideMin = 1440;
}

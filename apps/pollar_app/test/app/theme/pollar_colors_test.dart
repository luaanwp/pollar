import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';

void main() {
  for (final colors in [PollarColors.light, PollarColors.dark]) {
    test(
      'credit identity text and focused controls keep contrast (${colors.canvas})',
      () {
        expect(
          _contrast(colors.creditForeground, colors.creditSurface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(colors.creditSecondary, colors.creditSurface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(colors.creditForeground, colors.creditHover),
          greaterThanOrEqualTo(3),
        );
      },
    );
    test(
      'overview hero text meets AA throughout its gradient (${colors.canvas})',
      () {
        for (var step = 0; step <= 20; step++) {
          final background = Color.lerp(
            colors.financialHeroStart,
            colors.financialHeroEnd,
            step / 20,
          )!;
          for (final text in [
            colors.financialHeroForeground,
            colors.financialHeroSecondary,
          ]) {
            expect(_contrast(text, background), greaterThanOrEqualTo(4.5));
          }
        }
      },
    );
    test(
      'financial solid surface keeps primary, secondary and financial colors readable (${colors.canvas})',
      () {
        expect(colors.financialSurface, colors.primarySoft);
        for (final foreground in [
          colors.textPrimary,
          colors.textSecondary,
          colors.success,
          colors.danger,
          colors.warning,
          colors.info,
        ]) {
          expect(
            _contrast(foreground, colors.financialSurface),
            greaterThanOrEqualTo(4.5),
          );
        }
      },
    );
  }
  test('compact light-theme text pairs meet WCAG AA contrast', () {
    const colors = PollarColors.light;

    expect(
      _contrast(colors.textMuted, colors.canvas),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(colors.success, colors.successSoft),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(colors.warning, colors.warningSoft),
      greaterThanOrEqualTo(4.5),
    );
  });
}

double _contrast(Color foreground, Color background) {
  final lighter = math.max(
    foreground.computeLuminance(),
    background.computeLuminance(),
  );
  final darker = math.min(
    foreground.computeLuminance(),
    background.computeLuminance(),
  );
  return (lighter + 0.05) / (darker + 0.05);
}

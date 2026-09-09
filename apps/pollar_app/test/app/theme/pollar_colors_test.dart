import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollar_app/app/theme/pollar_theme.dart';

void main() {
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

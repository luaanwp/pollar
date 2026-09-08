import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';

enum PollarStatusTone { neutral, info, success, warning, danger }

/// Compact status label. Callers should pair the text with an [icon] whenever
/// the status has a recognized symbol so meaning never depends on color alone.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = PollarStatusTone.neutral,
    this.icon,
    this.compact = false,
  });

  final String label;
  final PollarStatusTone tone;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context.pollar);
    return Semantics(
      label: label,
      container: true,
      child: Container(
        constraints: BoxConstraints(minHeight: compact ? 20 : 24),
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(PollarRadii.pill),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon case final icon?) ...[
              Icon(icon, size: compact ? 12 : 14, color: colors.foreground),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: ExcludeSemantics(
                child: Text(
                  label,
                  maxLines: MediaQuery.textScalerOf(context).scale(1) > 1.3
                      ? 2
                      : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.foreground,
                    fontFamily: PollarTypography.fontFamily,
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusColors _colors(PollarColors colors) => switch (tone) {
    PollarStatusTone.neutral => _StatusColors(
      foreground: colors.textSecondary,
      background: colors.surfaceAlt,
      border: colors.border,
    ),
    PollarStatusTone.info => _StatusColors(
      foreground: colors.info,
      background: colors.infoSoft,
      border: Colors.transparent,
    ),
    PollarStatusTone.success => _StatusColors(
      foreground: colors.success,
      background: colors.successSoft,
      border: Colors.transparent,
    ),
    PollarStatusTone.warning => _StatusColors(
      foreground: colors.warning,
      background: colors.warningSoft,
      border: Colors.transparent,
    ),
    PollarStatusTone.danger => _StatusColors(
      foreground: colors.danger,
      background: colors.dangerSoft,
      border: Colors.transparent,
    ),
  };
}

class _StatusColors {
  const _StatusColors({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;
}

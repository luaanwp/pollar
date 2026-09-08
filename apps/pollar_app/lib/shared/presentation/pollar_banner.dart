import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/pollar_theme.dart';
import 'status_badge.dart';
import 'pollar_button.dart';

/// Persistent inline feedback for offline, sync, conflict, and informational
/// states. Critical recovery actions belong here rather than in a toast.
class PollarBanner extends StatelessWidget {
  const PollarBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = PollarStatusTone.info,
    this.icon,
    this.actions = const [],
    this.onDismiss,
  });

  final String? title;
  final String message;
  final PollarStatusTone tone;
  final IconData? icon;
  final List<Widget> actions;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    final colors = _toneColors(pollar);
    final alert = tone == PollarStatusTone.danger;

    return Semantics(
      container: true,
      liveRegion: true,
      label: [title, message].whereType<String>().join('. '),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PollarSpacing.x3,
          vertical: PollarSpacing.x3,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: pollar.border),
          borderRadius: BorderRadius.circular(PollarRadii.medium),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                icon ?? _defaultIcon,
                size: 18,
                color: colors.foreground,
              ),
            ),
            const SizedBox(width: PollarSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title case final title?) ...[
                    ExcludeSemantics(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: PollarSpacing.x1),
                  ],
                  ExcludeSemantics(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: pollar.textSecondary),
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: PollarSpacing.x2),
                    Wrap(spacing: PollarSpacing.x2, children: actions),
                  ],
                ],
              ),
            ),
            if (onDismiss case final onDismiss?)
              PollarIconButton(
                label: alert ? 'Fechar alerta' : 'Fechar aviso',
                icon: LucideIcons.x,
                size: PollarControlSize.compact,
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }

  IconData get _defaultIcon => switch (tone) {
    PollarStatusTone.info => LucideIcons.info,
    PollarStatusTone.success => LucideIcons.circleCheck,
    PollarStatusTone.warning => LucideIcons.triangleAlert,
    PollarStatusTone.danger => LucideIcons.circleAlert,
    PollarStatusTone.neutral => LucideIcons.info,
  };

  _BannerColors _toneColors(PollarColors colors) => switch (tone) {
    PollarStatusTone.info => _BannerColors(colors.info, colors.infoSoft),
    PollarStatusTone.success => _BannerColors(
      colors.success,
      colors.successSoft,
    ),
    PollarStatusTone.warning => _BannerColors(
      colors.warning,
      colors.warningSoft,
    ),
    PollarStatusTone.danger => _BannerColors(colors.danger, colors.dangerSoft),
    PollarStatusTone.neutral => _BannerColors(
      colors.textSecondary,
      colors.surfaceAlt,
    ),
  };
}

class _BannerColors {
  const _BannerColors(this.foreground, this.background);

  final Color foreground;
  final Color background;
}

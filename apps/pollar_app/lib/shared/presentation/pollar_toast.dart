import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/pollar_theme.dart';
import 'pollar_banner.dart';
import 'status_badge.dart';

/// Shows transient feedback for low-risk outcomes. Persistent recovery belongs
/// in [PollarBanner], not in a toast.
void showPollarToast(
  BuildContext context, {
  required String message,
  PollarStatusTone tone = PollarStatusTone.success,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final colors = context.pollar;
  final (icon, color) = switch (tone) {
    PollarStatusTone.success => (LucideIcons.circleCheck, colors.success),
    PollarStatusTone.info => (LucideIcons.info, colors.info),
    PollarStatusTone.warning => (LucideIcons.triangleAlert, colors.warning),
    PollarStatusTone.danger => (LucideIcons.circleAlert, colors.danger),
    PollarStatusTone.neutral => (LucideIcons.info, colors.textSecondary),
  };

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      showCloseIcon: actionLabel == null,
      content: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: PollarSpacing.x3),
          Expanded(child: Text(message)),
        ],
      ),
      action: actionLabel == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
    ),
  );
}

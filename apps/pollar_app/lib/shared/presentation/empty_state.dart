import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';

/// Centered empty/placeholder state: an outline icon, a title, and a line that
/// describes the state plus the next step. Used for routes whose feature has
/// not landed yet and for genuine empty data states.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    final text = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(PollarSpacing.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: pollar.textMuted),
              const SizedBox(height: PollarSpacing.x4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: text.headlineSmall,
              ),
              const SizedBox(height: PollarSpacing.x2),
              Text(
                message,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: pollar.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

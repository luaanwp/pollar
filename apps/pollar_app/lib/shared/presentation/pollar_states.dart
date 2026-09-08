import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/pollar_theme.dart';
import 'pollar_button.dart';

/// Centered loading state with calm, specific copy.
class PollarLoadingState extends StatelessWidget {
  const PollarLoadingState({
    super.key,
    this.message = 'Carregando informações…',
  });

  final String message;

  @override
  Widget build(BuildContext context) => _PollarStateLayout(
    visual: MediaQuery.disableAnimationsOf(context)
        ? Icon(LucideIcons.loaderCircle, size: 24, color: context.pollar.info)
        : SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.pollar.info,
            ),
          ),
    title: message,
    liveRegion: true,
  );
}

/// Recoverable error state. The action names the recovery operation.
class PollarErrorState extends StatelessWidget {
  const PollarErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onRetry,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _PollarStateLayout(
    visual: Icon(
      LucideIcons.circleAlert,
      size: 28,
      color: context.pollar.danger,
    ),
    title: title,
    message: message,
    action: PollarButton(
      label: actionLabel,
      variant: PollarButtonVariant.secondary,
      onPressed: onRetry,
    ),
    liveRegion: true,
  );
}

class _PollarStateLayout extends StatelessWidget {
  const _PollarStateLayout({
    required this.visual,
    required this.title,
    this.message,
    this.action,
    this.liveRegion = false,
  });

  final Widget visual;
  final String title;
  final String? message;
  final Widget? action;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: liveRegion,
    container: true,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(PollarSpacing.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              visual,
              const SizedBox(height: PollarSpacing.x4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (message case final message?) ...[
                const SizedBox(height: PollarSpacing.x2),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: context.pollar.textSecondary),
                ),
              ],
              if (action case final action?) ...[
                const SizedBox(height: PollarSpacing.x4),
                action,
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

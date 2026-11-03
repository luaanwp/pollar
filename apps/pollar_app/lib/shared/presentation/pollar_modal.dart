import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/pollar_theme.dart';
import 'pollar_button.dart';
import 'pollar_motion.dart';

enum PollarModalTone { standard, danger }

typedef PollarModalActions = List<Widget> Function(BuildContext context);

// THESIS: uma decisão continua alcançável acima do teclado e das áreas do sistema.
// OWN-WORLD: folhas e diálogos nativos no canvas sólido e na tipografia Pollar.
// STORY: ler, preencher e confirmar sem perder o rascunho ao abrir o teclado.
// FIRST VIEWPORT: conteúdo e ações rolam numa área limitada acima do IME; área de gestos fica livre.
// FORM: extensão adaptativa dos modais existentes, sem nova identidade visual.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md
/// Opens a sheet on compact/short viewports, otherwise a native dialog.
Future<T?> showPollarAdaptiveModal<T>({
  required BuildContext context,
  required String title,
  required String description,
  required PollarModalActions actions,
  WidgetBuilder? content,
  PollarModalTone tone = PollarModalTone.standard,
  IconData? icon,
  bool dismissible = true,
}) {
  final media = MediaQuery.of(context);
  final compact =
      media.size.width < PollarBreakpoints.mediumMin ||
      media.size.height - media.viewInsets.bottom - media.padding.top < 480;
  if (compact) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: dismissible,
      enableDrag: dismissible,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: PollarMotion.reduced(context)
          ? AnimationStyle.noAnimation
          : null,
      builder: (modalContext) => _PollarBottomSheet(
        title: title,
        description: description,
        tone: tone,
        icon: icon,
        content: content?.call(modalContext),
        actions: actions(modalContext),
        showClose: dismissible,
      ),
    );
  }

  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierColor: context.pollar.textPrimary.withValues(alpha: 0.36),
    animationStyle: PollarMotion.reduced(context)
        ? AnimationStyle.noAnimation
        : null,
    builder: (dialogContext) => PollarDecisionDialog(
      title: title,
      description: description,
      tone: tone,
      icon: icon,
      content: content?.call(dialogContext),
      actions: actions(dialogContext),
    ),
  );
}

/// Focused desktop decision surface. Actions should name their object.
class PollarDecisionDialog extends StatelessWidget {
  const PollarDecisionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.actions,
    this.tone = PollarModalTone.standard,
    this.icon,
    this.content,
  });

  final String title;
  final String description;
  final List<Widget> actions;
  final PollarModalTone tone;
  final IconData? icon;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final colors = context.pollar;
    final danger = tone == PollarModalTone.danger;
    final accent = danger ? colors.danger : colors.primary;

    return AlertDialog(
      scrollable: true,
      semanticLabel: title,
      iconPadding: const EdgeInsets.fromLTRB(
        PollarSpacing.x5,
        PollarSpacing.x5,
        PollarSpacing.x3,
        0,
      ),
      icon: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: danger ? colors.dangerSoft : colors.primarySoft,
            borderRadius: BorderRadius.circular(PollarRadii.medium),
          ),
          child: Icon(
            icon ?? (danger ? LucideIcons.triangleAlert : LucideIcons.info),
            size: 20,
            color: accent,
          ),
        ),
      ),
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.textSecondary),
            ),
            if (content case final content?) ...[
              const SizedBox(height: PollarSpacing.x4),
              content,
            ],
          ],
        ),
      ),
      actions: actions,
    );
  }
}

class _PollarBottomSheet extends StatelessWidget {
  const _PollarBottomSheet({
    required this.title,
    required this.description,
    required this.actions,
    required this.tone,
    this.icon,
    this.content,
    required this.showClose,
  });

  final String title;
  final String description;
  final List<Widget> actions;
  final PollarModalTone tone;
  final IconData? icon;
  final Widget? content;
  final bool showClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.pollar;
    final danger = tone == PollarModalTone.danger;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: Material(
          color: colors.canvas,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(PollarRadii.large),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                PollarSpacing.x4,
                PollarSpacing.x2,
                PollarSpacing.x4,
                PollarSpacing.x4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.borderStrong,
                        borderRadius: BorderRadius.circular(PollarRadii.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: PollarSpacing.x4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        icon ??
                            (danger
                                ? LucideIcons.triangleAlert
                                : LucideIcons.info),
                        size: 20,
                        color: danger ? colors.danger : colors.primary,
                      ),
                      const SizedBox(width: PollarSpacing.x3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: PollarSpacing.x2),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (showClose)
                        PollarIconButton(
                          label: 'Fechar',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: LucideIcons.x,
                        ),
                    ],
                  ),
                  if (content case final content?) ...[
                    const SizedBox(height: PollarSpacing.x4),
                    content,
                  ],
                  const SizedBox(height: PollarSpacing.x5),
                  for (final action in actions) ...[
                    SizedBox(width: double.infinity, child: action),
                    if (action != actions.last)
                      const SizedBox(height: PollarSpacing.x2),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

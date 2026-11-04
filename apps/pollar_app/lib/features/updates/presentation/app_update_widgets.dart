import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_modal.dart';
import 'app_update_controller.dart';

class AppUpdateWatcher extends ConsumerStatefulWidget {
  const AppUpdateWatcher({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AppUpdateWatcher> createState() => _AppUpdateWatcherState();
}

class _AppUpdateWatcherState extends ConsumerState<AppUpdateWatcher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(ref.read(appUpdateProvider.notifier).check());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(appUpdateProvider.notifier).check());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Settings always offers a manual check; the shell only announces a release.
class AppUpdatePanel extends ConsumerWidget {
  const AppUpdatePanel({super.key, this.noticeOnly = false});
  final bool noticeOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateway = ref.watch(appUpdateGatewayProvider);
    if (gateway == null || !gateway.supported) return const SizedBox.shrink();
    final state = ref.watch(appUpdateProvider);
    if (noticeOnly && state.release == null) return const SizedBox.shrink();
    final controller = ref.read(appUpdateProvider.notifier);
    final ready = state.file != null;
    final label = ready
        ? Theme.of(context).platform == TargetPlatform.windows
              ? 'Atualizar e reiniciar'
              : 'Instalar atualização'
        : state.release != null
        ? 'Atualizar'
        : 'Verificar atualizações';
    final title = switch (state.phase) {
      AppUpdatePhase.downloading =>
        'Baixando atualização… ${(state.progress * 100).round()}%',
      AppUpdatePhase.installing => 'Preparando instalação…',
      AppUpdatePhase.checking => 'Verificando atualizações…',
      _ when state.release != null => 'Nova versão disponível',
      AppUpdatePhase.current => 'Pollar atualizado',
      _ => 'Atualizações do Pollar',
    };
    final description =
        state.message ??
        (state.release != null
            ? 'Versão ${state.release!.version}. Seus dados serão mantidos.'
            : 'Versão instalada: ${gateway.installed}.');
    return Padding(
      padding: noticeOnly
          ? const EdgeInsets.fromLTRB(16, 8, 16, 8)
          : EdgeInsets.zero,
      child: PollarCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final details = Semantics(
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: PollarSpacing.x1),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: context.pollar.textSecondary),
                  ),
                ],
              ),
            );
            final action = PollarButton(
              label: label,
              leadingIcon: LucideIcons.download,
              loading: state.busy,
              adaptiveHeight: true,
              onPressed: state.busy
                  ? null
                  : () async {
                      if (ready) {
                        final confirm = await showPollarAdaptiveModal<bool>(
                          context: context,
                          title: 'Instalar atualização?',
                          description:
                              Theme.of(context).platform ==
                                  TargetPlatform.windows
                              ? 'Conclua o que estiver editando. O Pollar será fechado e reaberto com a nova versão. Seus dados serão mantidos.'
                              : 'O Android pedirá sua confirmação para atualizar o Pollar. Seus dados serão mantidos.',
                          actions: (modalContext) => [
                            PollarButton(
                              label: 'Agora não',
                              variant: PollarButtonVariant.secondary,
                              onPressed: () =>
                                  Navigator.of(modalContext).pop(false),
                            ),
                            PollarButton(
                              label: 'Instalar atualização',
                              adaptiveHeight: true,
                              onPressed: () =>
                                  Navigator.of(modalContext).pop(true),
                            ),
                          ],
                        );
                        if (confirm == true) await controller.install();
                      } else if (state.release != null) {
                        await controller.download();
                      } else {
                        await controller.check(force: true);
                      }
                    },
            );
            if (constraints.maxWidth < 680 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.3) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  details,
                  const SizedBox(height: PollarSpacing.x3),
                  action,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: details),
                const SizedBox(width: PollarSpacing.x4),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

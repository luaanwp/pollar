import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../shared/presentation/pollar_banner.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/status_badge.dart';
import 'sync_controller.dart';

class IdentityMismatchScreen extends ConsumerWidget {
  const IdentityMismatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(PollarSpacing.x4),
            children: [
              PollarCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.shieldAlert,
                      color: context.pollar.warning,
                      size: 28,
                    ),
                    const SizedBox(height: PollarSpacing.x4),
                    Text(
                      'Estes dados pertencem a outra conta',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: PollarSpacing.x3),
                    const PollarBanner(
                      tone: PollarStatusTone.warning,
                      title: 'Troca protegida',
                      message: 'O Pollar bloqueou o acesso para não misturar nem enviar o livro-caixa local para outra pessoa.',
                    ),
                    const SizedBox(height: PollarSpacing.x4),
                    Text(
                      'Saia e entre com a conta que sincronizou este dispositivo. Seus registros locais não foram alterados.',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: context.pollar.textSecondary),
                    ),
                    const SizedBox(height: PollarSpacing.x5),
                    PollarButton(
                      label: 'Sair desta conta',
                      variant: PollarButtonVariant.secondary,
                      onPressed: () =>
                          ref.read(syncSessionAccessProvider).signOut(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

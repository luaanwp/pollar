import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../app/theme/theme_mode_provider.dart';

/// Preferences ("Preferências") — the settings surface. For now it exposes the
/// theme choice; persisted preferences and account settings land later.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollar = context.pollar;
    final text = Theme.of(context).textTheme;
    final mode = ref.watch(themeModeProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PollarSizes.dashboardMax),
        child: ListView(
          padding: const EdgeInsets.all(PollarSpacing.x6),
          children: [
            Text(
              'APARÊNCIA',
              style: PollarTypography.eyebrow.copyWith(color: pollar.textMuted),
            ),
            const SizedBox(height: PollarSpacing.x3),
            Card(
              child: Column(
                children: [
                  _ThemeOption(
                    icon: LucideIcons.sunMedium,
                    label: 'Tema claro',
                    selected: mode == ThemeMode.light,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .set(ThemeMode.light),
                  ),
                  Divider(height: 1, color: pollar.border),
                  _ThemeOption(
                    icon: LucideIcons.moon,
                    label: 'Tema escuro',
                    selected: mode == ThemeMode.dark,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .set(ThemeMode.dark),
                  ),
                  Divider(height: 1, color: pollar.border),
                  _ThemeOption(
                    icon: LucideIcons.monitor,
                    label: 'Seguir o sistema',
                    selected: mode == ThemeMode.system,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .set(ThemeMode.system),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PollarSpacing.x4),
            Text(
              'A escolha ainda não é salva entre sessões; a preferência '
              'persistida chega com o restante das configurações.',
              style: text.bodySmall?.copyWith(color: pollar.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pollar = context.pollar;
    final text = Theme.of(context).textTheme;
    final color = selected ? pollar.primary : pollar.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PollarSpacing.x5,
          vertical: PollarSpacing.x4,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: PollarSpacing.x3),
            Expanded(
              child: Text(
                label,
                style: text.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              Icon(LucideIcons.check, size: 20, color: pollar.primary),
          ],
        ),
      ),
    );
  }
}

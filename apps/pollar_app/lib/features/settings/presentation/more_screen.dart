import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../shared/presentation/pollar_card.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: PollarSizes.dashboardMax),
      child: ListView(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin
              ? PollarSpacing.x4
              : PollarSpacing.x6,
        ),
        children: [
          Text('Mais', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: PollarSpacing.x1),
          Text(
            'Patrimônio, preferências e os próximos controles da conta.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: context.pollar.textSecondary),
          ),
          const SizedBox(height: PollarSpacing.x6),
          _MoreDestination(
            icon: LucideIcons.scale,
            title: 'Patrimônio',
            description: 'Metas, ativos, dívidas e patrimônio líquido.',
            onTap: () => context.push('/more/wealth'),
          ),
          const SizedBox(height: PollarSpacing.x3),
          _MoreDestination(
            icon: LucideIcons.settings,
            title: 'Preferências',
            description: 'Aparência e configurações do aplicativo.',
            onTap: () => context.push('/more/settings'),
          ),
        ],
      ),
    ),
  );
}

class _MoreDestination extends StatelessWidget {
  const _MoreDestination({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PollarCard(
    onTap: onTap,
    semanticLabel: '$title. $description',
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.pollar.primarySoft,
            borderRadius: BorderRadius.circular(PollarRadii.medium),
          ),
          child: Icon(icon, size: 20, color: context.pollar.primary),
        ),
        const SizedBox(width: PollarSpacing.x4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: PollarSpacing.x1),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.pollar.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: PollarSpacing.x3),
        Icon(
          LucideIcons.chevronRight,
          size: 20,
          color: context.pollar.textMuted,
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';

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
            'Análises do livro-caixa e controles do aplicativo.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: context.pollar.textSecondary),
          ),
          const SizedBox(height: PollarSpacing.x6),
          const _SectionHeading('Entenda seus dados'),
          _MoreDestination(
            icon: LucideIcons.chartNoAxesCombined,
            title: 'Relatórios',
            description:
                'Comparações mensais, categorias e exportação verificável.',
            onTap: () => context.push('/more/reports'),
          ),
          const Divider(height: 1),
          _MoreDestination(
            icon: LucideIcons.scale,
            title: 'Patrimônio',
            description: 'Metas, ativos, dívidas e patrimônio líquido.',
            onTap: () => context.push('/more/wealth'),
          ),
          const SizedBox(height: PollarSpacing.x8),
          const _SectionHeading('Seu aplicativo'),
          _MoreDestination(
            icon: LucideIcons.cloudCog,
            title: 'Sincronização',
            description:
                'Conta, fila deste dispositivo e conflitos preservados.',
            onTap: () => context.push('/more/sync'),
          ),
          const Divider(height: 1),
          _MoreDestination(
            icon: LucideIcons.databaseBackup,
            title: 'Dados e backup',
            description:
                'Cópia completa, verificação e restauração dos dados locais.',
            onTap: () => context.push('/more/data'),
          ),
          const Divider(height: 1),
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: PollarSpacing.x2),
    child: Semantics(
      header: true,
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    ),
  );
}

class _MoreDestination extends StatefulWidget {
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
  State<_MoreDestination> createState() => _MoreDestinationState();
}

class _MoreDestinationState extends State<_MoreDestination> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PollarRadii.medium),
      side: BorderSide(
        color: _focused ? context.pollar.info : Colors.transparent,
        width: 2,
      ),
    ),
    child: ListTile(
      onTap: widget.onTap,
      onFocusChange: (focused) => setState(() => _focused = focused),
      focusColor: context.pollar.primarySoft,
      hoverColor: context.pollar.surfaceAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PollarRadii.medium),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PollarSpacing.x3,
        vertical: PollarSpacing.x3,
      ),
      minTileHeight: PollarSizes.androidTouchTargetMin,
      leading: Icon(widget.icon, size: 20, color: context.pollar.textSecondary),
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: PollarSpacing.x1),
        child: Text(
          widget.description,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: context.pollar.textSecondary),
        ),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 20,
        color: context.pollar.textMuted,
      ),
    ),
  );
}

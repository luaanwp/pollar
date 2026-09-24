// THESIS: O backup é um inventário verificável antes de ser uma ação; recusa restaurações opacas e atalhos destrutivos.
// OWN-WORLD: Superfícies planas contornadas, teal restrito, números tabulares e avisos semânticos do Pollar.
// STORY: A pessoa confere o que está neste dispositivo, cria uma cópia e só substitui dados após validar arquivo e impacto.
// FIRST VIEWPORT: Título e aviso antecedem um inventário compacto; criar e selecionar backup fecham a leitura principal.
// FORM: Extensão operacional do livro-caixa sereno, herdando o sistema estabelecido sem concept seed.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../shared/presentation/pollar_banner.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_modal.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/pollar_toast.dart';
import '../../../shared/presentation/status_badge.dart';
import '../domain/data_backup.dart';
import 'data_management_controller.dart';

class DataManagementScreen extends ConsumerWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(dataManagementProvider);
    return inventory.when(
      loading: () => const PollarLoadingState(
        message: 'Conferindo os dados deste dispositivo…',
      ),
      error: (error, stackTrace) => PollarErrorState(
        title: 'Não foi possível conferir os dados',
        message:
            'Os dados continuam salvos. Tente carregar o inventário novamente.',
        actionLabel: 'Recarregar inventário',
        onRetry: ref.read(dataManagementProvider.notifier).retry,
      ),
      data: (value) => _DataManagementContent(inventory: value),
    );
  }
}

class _DataManagementContent extends ConsumerStatefulWidget {
  const _DataManagementContent({required this.inventory});

  final DataInventory inventory;

  @override
  ConsumerState<_DataManagementContent> createState() =>
      _DataManagementContentState();
}

class _DataManagementContentState
    extends ConsumerState<_DataManagementContent> {
  var _exporting = false;
  var _selecting = false;
  var _restoring = false;

  bool get _busy => _exporting || _selecting || _restoring;

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: ListView(
          padding: EdgeInsets.all(
            compact ? PollarSpacing.x4 : PollarSpacing.x6,
          ),
          children: [
            Text(
              'Dados e backup',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: PollarSpacing.x1),
            Text(
              'Proteja uma cópia completa dos registros salvos neste dispositivo.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.pollar.textSecondary),
            ),
            const SizedBox(height: PollarSpacing.x5),
            const PollarBanner(
              title: 'Arquivo sem criptografia',
              message: 'O backup contém seus dados financeiros em texto legível. Guarde-o em um local privado e não o envie a terceiros.',
              tone: PollarStatusTone.warning,
              icon: LucideIcons.shieldAlert,
            ),
            const SizedBox(height: PollarSpacing.x4),
            _InventoryCard(inventory: widget.inventory),
            const SizedBox(height: PollarSpacing.x4),
            _BackupActions(
              compact: compact,
              exporting: _exporting,
              selecting: _selecting,
              disabled: _busy,
              onExport: _createBackup,
              onSelect: _chooseBackup,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() => _exporting = true);
    try {
      final result = await ref
          .read(dataManagementProvider.notifier)
          .createBackup();
      if (!mounted) return;
      showPollarToast(context, message: 'Backup criado em ${result.path}.');
    } catch (_) {
      if (!mounted) return;
      showPollarToast(
        context,
        message: 'Não foi possível criar o backup. Verifique o armazenamento e tente novamente.',
        tone: PollarStatusTone.danger,
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _chooseBackup() async {
    setState(() => _selecting = true);
    try {
      final backup = await ref
          .read(dataManagementProvider.notifier)
          .chooseBackup();
      if (!mounted || backup == null) return;
      final confirmed = await _confirmRestore(backup);
      if (!mounted || confirmed != true) return;
      setState(() => _restoring = true);
      try {
        await ref.read(dataManagementProvider.notifier).restore(backup);
        if (!mounted) return;
        showPollarToast(
          context,
          message: 'Backup restaurado. Os dados locais foram atualizados.',
        );
      } catch (error) {
        if (!mounted) return;
        final message = error is BackupValidationException
            ? error.message
            : 'Não foi possível restaurar o backup. Os dados atuais foram preservados.';
        showPollarToast(
          context,
          message: message,
          tone: PollarStatusTone.danger,
        );
      } finally {
        if (mounted) setState(() => _restoring = false);
      }
    } on BackupValidationException catch (error) {
      if (!mounted) return;
      showPollarToast(
        context,
        message: error.message,
        tone: PollarStatusTone.danger,
      );
    } catch (_) {
      if (!mounted) return;
      showPollarToast(
        context,
        message: 'Não foi possível abrir o arquivo. Escolha um backup JSON do Pollar.',
        tone: PollarStatusTone.danger,
      );
    } finally {
      if (mounted) setState(() => _selecting = false);
    }
  }

  Future<bool?> _confirmRestore(ValidatedBackup backup) {
    final preview = backup.preview;
    return showPollarAdaptiveModal<bool>(
      context: context,
      title: 'Substituir dados locais?',
      description: 'Todos os dados atuais deste dispositivo serão substituídos pelos registros abaixo. Essa ação só pode ser desfeita com outro backup.',
      tone: PollarModalTone.danger,
      icon: LucideIcons.databaseBackup,
      content: (_) => _BackupPreviewContent(preview: preview),
      actions: (modalContext) => [
        PollarButton(
          label: 'Manter dados atuais',
          variant: PollarButtonVariant.secondary,
          onPressed: () => Navigator.of(modalContext).pop(false),
        ),
        PollarButton(
          label: 'Substituir dados locais',
          variant: PollarButtonVariant.danger,
          onPressed: () => Navigator.of(modalContext).pop(true),
        ),
      ],
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.inventory});

  final DataInventory inventory;

  @override
  Widget build(BuildContext context) {
    final reflow = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final title = Row(
      children: [
        Icon(LucideIcons.database, size: 20, color: context.pollar.primary),
        const SizedBox(width: PollarSpacing.x3),
        Expanded(
          child: Text(
            'Neste dispositivo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
    final total = Text(
      '${inventory.totalRecords} registros',
      textAlign: reflow ? TextAlign.start : TextAlign.end,
      style: PollarTypography.tabular(Theme.of(context).textTheme.bodySmall!)
          .copyWith(color: context.pollar.textSecondary),
    );
    return PollarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (reflow) ...[
            title,
            const SizedBox(height: PollarSpacing.x2),
            total,
          ] else
            Row(
              children: [
                Expanded(child: title),
                const SizedBox(width: PollarSpacing.x3),
                total,
              ],
            ),
          const SizedBox(height: PollarSpacing.x4),
          _InventoryRow(label: 'Contas', value: inventory.accounts),
          _InventoryRow(label: 'Lançamentos', value: inventory.transactions),
          _InventoryRow(
            label: 'Planejamento',
            value: inventory.planningRecords,
          ),
          _InventoryRow(label: 'Patrimônio', value: inventory.wealthRecords),
        ],
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: PollarSpacing.x2),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          '$value',
          style: PollarTypography.tabular(
            Theme.of(context).textTheme.titleMedium!,
          ),
        ),
      ],
    ),
  );
}

class _BackupActions extends StatelessWidget {
  const _BackupActions({
    required this.compact,
    required this.exporting,
    required this.selecting,
    required this.disabled,
    required this.onExport,
    required this.onSelect,
  });

  final bool compact;
  final bool exporting;
  final bool selecting;
  final bool disabled;
  final VoidCallback onExport;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final create = PollarButton(
      label: 'Criar backup',
      leadingIcon: LucideIcons.download,
      loading: exporting,
      fullWidth: compact,
      onPressed: disabled ? null : onExport,
    );
    final select = PollarButton(
      label: 'Selecionar backup',
      leadingIcon: LucideIcons.folderOpen,
      variant: PollarButtonVariant.secondary,
      loading: selecting,
      fullWidth: compact,
      onPressed: disabled ? null : onSelect,
    );
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          create,
          const SizedBox(height: PollarSpacing.x2),
          select,
        ],
      );
    }
    return Row(
      children: [
        create,
        const SizedBox(width: PollarSpacing.x3),
        select,
      ],
    );
  }
}

class _BackupPreviewContent extends StatelessWidget {
  const _BackupPreviewContent({required this.preview});

  final BackupPreview preview;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      "dd/MM/yyyy 'às' HH:mm",
      'pt_BR',
    ).format(preview.createdAt);
    return Container(
      padding: const EdgeInsets.all(PollarSpacing.x4),
      decoration: BoxDecoration(
        color: context.pollar.surfaceAlt,
        borderRadius: BorderRadius.circular(PollarRadii.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            preview.fileName,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: PollarSpacing.x3),
          _PreviewRow(label: 'Criado em', value: date),
          _PreviewRow(
            label: 'Versão dos dados',
            value: '${preview.databaseSchema}',
          ),
          _PreviewRow(label: 'Contas', value: '${preview.inventory.accounts}'),
          _PreviewRow(
            label: 'Lançamentos',
            value: '${preview.inventory.transactions}',
          ),
          _PreviewRow(
            label: 'Planejamento',
            value: '${preview.inventory.planningRecords}',
          ),
          _PreviewRow(
            label: 'Patrimônio',
            value: '${preview.inventory.wealthRecords}',
          ),
          const SizedBox(height: PollarSpacing.x2),
          Row(
            children: [
              Icon(
                LucideIcons.badgeCheck,
                size: 16,
                color: context.pollar.success,
              ),
              const SizedBox(width: PollarSpacing.x2),
              Expanded(
                child: Text(
                  'SHA-256 verificado · ${preview.checksum.substring(0, 12)}…',
                  style: PollarTypography.tabular(
                    Theme.of(context).textTheme.bodySmall!,
                  ).copyWith(color: context.pollar.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: PollarSpacing.x1),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.pollar.textSecondary),
          ),
        ),
        const SizedBox(width: PollarSpacing.x3),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: PollarTypography.tabular(
              Theme.of(context).textTheme.bodySmall!,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

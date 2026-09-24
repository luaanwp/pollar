// THESIS: Sync is a visible ledger operation, never a vague cloud promise.
// OWN-WORLD: Calm bordered surfaces, exact counts, and teal reserved for action.
// STORY: See local safety, send changes, and explicitly arbitrate every conflict.
// FIRST VIEWPORT: Status, pending work, and the primary sync action stay together.
// FORM: Operational console inside the established quiet bookkeeping system.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../core/money/money_formatter.dart';
import '../../../shared/presentation/pollar_banner.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/status_badge.dart';
import '../domain/sync_models.dart';
import 'sync_controller.dart';

class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncControllerProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PollarSizes.dashboardMax),
        child: ListView(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin
                ? PollarSpacing.x4
                : PollarSpacing.x6,
          ),
          children: [
            Text(
              'Sincronização',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: PollarSpacing.x1),
            Text(
              'Controle o que sai deste dispositivo e resolva divergências sem perder registros.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.pollar.textSecondary),
            ),
            const SizedBox(height: PollarSpacing.x6),
            state.when(
              loading: () => const PollarLoadingState(
                message: 'Lendo estado da sincronização',
              ),
              error: (error, _) => PollarErrorState(
                title: 'Não foi possível ler a sincronização',
                message: error.toString(),
                actionLabel: 'Tentar novamente',
                onRetry: () => ref.invalidate(syncControllerProvider),
              ),
              data: (overview) => _SyncContent(overview: overview),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncContent extends ConsumerWidget {
  const _SyncContent({required this.overview});

  final SyncOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localOnly = overview.phase == SyncPhase.localOnly;
    final syncing = overview.phase == SyncPhase.syncing;
    final session = ref.watch(syncSessionAccessProvider);
    final conflicts = ref.watch(syncConflictsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PollarBanner(
          title: localOnly
              ? 'Somente neste dispositivo'
              : _statusTitle(overview.phase),
          message: overview.message ?? _statusMessage(overview),
          tone: _statusTone(overview.phase),
          icon: localOnly ? LucideIcons.hardDrive : LucideIcons.refreshCw,
        ),
        const SizedBox(height: PollarSpacing.x4),
        PollarCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: PollarSpacing.x3,
                runSpacing: PollarSpacing.x2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Fila deste dispositivo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  StatusBadge(
                    label: overview.pendingCount == 1
                        ? '1 pendente'
                        : '${overview.pendingCount} pendentes',
                    tone: overview.pendingCount == 0
                        ? PollarStatusTone.success
                        : PollarStatusTone.warning,
                  ),
                ],
              ),
              const SizedBox(height: PollarSpacing.x2),
              Text(
                localOnly
                    ? 'Os registros estão salvos localmente. Configure o Supabase no início do app para habilitar conta e múltiplos dispositivos.'
                    : 'As mudanças entram nesta fila antes de serem enviadas. Repetições usam o mesmo identificador e não duplicam lançamentos.',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.pollar.textSecondary),
              ),
              if (!localOnly) ...[
                const SizedBox(height: PollarSpacing.x4),
                PollarButton(
                  label: 'Sincronizar agora',
                  leadingIcon: LucideIcons.refreshCw,
                  loading: syncing,
                  onPressed: syncing
                      ? null
                      : () => ref
                            .read(syncControllerProvider.notifier)
                            .synchronize(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: PollarSpacing.x4),
        if (!localOnly)
          _IdentityCard(
            email: session.email,
            lastSyncedAt: overview.lastSyncedAt,
          ),
        if (!localOnly) const SizedBox(height: PollarSpacing.x4),
        conflicts.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (items) => _ConflictSection(items: items),
        ),
      ],
    );
  }

  String _statusTitle(SyncPhase phase) => switch (phase) {
    SyncPhase.syncing => 'Sincronizando',
    SyncPhase.conflict => 'Decisão necessária',
    SyncPhase.error => 'Sincronização pausada',
    _ => 'Dados em dia',
  };

  String _statusMessage(SyncOverview value) => switch (value.phase) {
    SyncPhase.localOnly =>
      'Seus dados continuam disponíveis e protegidos no armazenamento local.',
    SyncPhase.syncing =>
      'Enviando a fila local e buscando mudanças do servidor.',
    SyncPhase.conflict =>
      value.conflictCount == 1
          ? '1 conflito preservado para revisão.'
          : '${value.conflictCount} conflitos preservados para revisão.',
    SyncPhase.error =>
      'As alterações continuam na fila local para uma nova tentativa.',
    _ =>
      value.lastSyncedAt == null
          ? 'Pronto para a primeira sincronização.'
          : 'Última sincronização concluída sem sobrescrever conflitos.',
  };

  PollarStatusTone _statusTone(SyncPhase phase) => switch (phase) {
    SyncPhase.conflict => PollarStatusTone.warning,
    SyncPhase.error || SyncPhase.offline => PollarStatusTone.danger,
    SyncPhase.idle => PollarStatusTone.success,
    _ => PollarStatusTone.info,
  };
}

class _IdentityCard extends ConsumerWidget {
  const _IdentityCard({required this.email, required this.lastSyncedAt});

  final String? email;
  final DateTime? lastSyncedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PollarCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Conta', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: PollarSpacing.x2),
        Text(email ?? 'Sessão autenticada'),
        const SizedBox(height: PollarSpacing.x1),
        Text(
          lastSyncedAt == null
              ? 'Ainda não sincronizado'
              : 'Última sincronização: ${DateFormat('dd/MM/yyyy HH:mm').format(lastSyncedAt!)}',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.pollar.textSecondary),
        ),
        const SizedBox(height: PollarSpacing.x4),
        PollarButton(
          label: 'Sair da conta',
          variant: PollarButtonVariant.secondary,
          onPressed: () => ref.read(syncSessionAccessProvider).signOut(),
        ),
      ],
    ),
  );
}

class _ConflictSection extends ConsumerWidget {
  const _ConflictSection({required this.items});

  final List<SyncConflictRecord> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CONFLITOS',
          style: PollarTypography.eyebrow.copyWith(
            color: context.pollar.textMuted,
          ),
        ),
        const SizedBox(height: PollarSpacing.x3),
        for (final item in items) ...[
          PollarCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.entityType == 'account'
                      ? 'Conta divergente'
                      : 'Lançamento divergente',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: PollarSpacing.x2),
                Text(
                  'As duas versões foram preservadas. Compare antes de escolher qual continuará.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: context.pollar.textSecondary),
                ),
                const SizedBox(height: PollarSpacing.x3),
                Wrap(
                  spacing: PollarSpacing.x2,
                  runSpacing: PollarSpacing.x2,
                  children: [
                    PollarButton(
                      label: 'Comparar versões',
                      variant: PollarButtonVariant.secondary,
                      onPressed: () => _showConflict(context, ref, item),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: PollarSpacing.x3),
        ],
      ],
    );
  }

  Future<void> _showConflict(
    BuildContext context,
    WidgetRef ref,
    SyncConflictRecord item,
  ) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Escolha a versão'),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: PollarSpacing.x4,
            runSpacing: PollarSpacing.x4,
            children: [
              _VersionPanel(
                title: 'Neste dispositivo',
                payload: item.localPayload,
              ),
              _VersionPanel(title: 'No servidor', payload: item.remotePayload),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await ref
                .read(syncControllerProvider.notifier)
                .resolve(item.id, keepLocal: false);
          },
          child: const Text('Usar servidor'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await ref
                .read(syncControllerProvider.notifier)
                .resolve(item.id, keepLocal: true);
          },
          child: const Text('Manter deste dispositivo'),
        ),
      ],
    ),
  );
}

class _VersionPanel extends StatelessWidget {
  const _VersionPanel({required this.title, required this.payload});

  final String title;
  final Map<String, Object?> payload;

  static const _hiddenFields = {
    'id',
    'account_id',
    'counter_account_id',
    'installment_group_id',
    'statement_id',
    'currency_decimal_digits',
    'currency_symbol',
  };

  static const _labels = {
    'id': 'Identificador',
    'name': 'Nome',
    'description': 'Descrição',
    'type': 'Tipo',
    'status': 'Estado',
    'currency_code': 'Moeda',
    'opening_balance_minor': 'Saldo inicial',
    'credit_limit_minor': 'Limite de crédito',
    'amount_minor': 'Valor',
    'purchase_total_minor': 'Total da compra',
    'account_id': 'Conta',
    'counter_account_id': 'Conta de destino',
    'account_name': 'Conta',
    'counter_account_name': 'Conta de destino',
    'occurred_at': 'Data',
    'category': 'Categoria',
    'note': 'Observação',
    'closing_day': 'Dia de fechamento',
    'due_day': 'Dia de vencimento',
    'installment_number': 'Parcela',
    'installment_count': 'Total de parcelas',
    'installment_group_id': 'Grupo de parcelas',
    'statement_id': 'Fatura',
  };

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 270,
    child: PollarCard(
      alt: true,
      padding: PollarCardPadding.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: PollarSpacing.x2),
          if (payload.isEmpty)
            const Text('Registro removido')
          else
            for (final entry in payload.entries.where(
              (entry) => !_hiddenFields.contains(entry.key),
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: PollarSpacing.x1),
                child: Text(
                  '${_labels[entry.key] ?? entry.key}: '
                  '${_formatValue(entry.key, entry.value)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
        ],
      ),
    ),
  );

  String _formatValue(String key, Object? value) {
    if (value == null) return '—';
    if (key.endsWith('_minor') && value is int) {
      final code = payload['currency_code'] as String? ?? 'BRL';
      final digits = payload['currency_decimal_digits'] as int? ?? 2;
      final symbol = payload['currency_symbol'] as String? ?? code;
      return const MoneyFormatter.ptBr().format(
        Money(
          minorUnits: value,
          currency: Currency(code: code, decimalDigits: digits, symbol: symbol),
        ),
      );
    }
    if (key == 'occurred_at' && value is String) {
      final parsed = DateTime.tryParse(value)?.toLocal();
      if (parsed != null) return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    }
    if (value is bool) return value ? 'Sim' : 'Não';
    if (key == 'type' || key == 'status') {
      return const {
            'income': 'Receita',
            'expense': 'Despesa',
            'transfer': 'Transferência',
            'cardPurchase': 'Compra no cartão',
            'cardStatementPayment': 'Pagamento de fatura',
            'cash': 'Dinheiro',
            'checking': 'Conta corrente',
            'savings': 'Poupança',
            'investment': 'Investimento',
            'creditCard': 'Cartão de crédito',
            'active': 'Ativa',
            'archived': 'Arquivada',
            'previsto': 'Previsto',
            'pendente': 'Pendente',
            'compensado': 'Compensado',
            'conciliado': 'Conciliado',
            'cancelado': 'Cancelado',
          }[value] ??
          value.toString();
    }
    return value.toString();
  }
}

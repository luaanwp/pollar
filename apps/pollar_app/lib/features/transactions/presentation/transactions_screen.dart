// THESIS: Um livro-caixa operacional torna impacto, conta e estado legíveis sem abrir cada item; recusa o dashboard de cartões iguais.
// OWN-WORLD: Superfícies planas claras, bordas finas, Inter, teal só em ação/seleção e cores semânticas contidas em badges.
// STORY: A pessoa busca ou filtra, confere o movimento e abre detalhes antes de cancelar sem apagar o histórico.
// FIRST VIEWPORT: Título e ação precedem busca/filtros; lista diária no mobile e ledger com painel contextual de 360 px no desktop.
// FORM: Ledger→detail no desktop e day-grouped list no mobile, estrutura Operate prescrita pelo design kit Pollar.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/privacy/privacy_mode_provider.dart';
import '../../../app/theme/pollar_theme.dart';
import '../../../core/ledger/balance_rules.dart';
import '../../../shared/presentation/empty_state.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_modal.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/pollar_text_field.dart';
import '../../../shared/presentation/pollar_toast.dart';
import '../../../shared/presentation/privacy_amount.dart';
import '../../../shared/presentation/status_badge.dart';
import '../../../shared/presentation/transaction_tile.dart';
import '../application/transaction_account_catalog.dart';
import '../domain/financial_transaction.dart';
import 'transaction_presentation.dart';
import 'transactions_controller.dart';

enum _TransactionFilter { all, income, expense, transfer }

extension on _TransactionFilter {
  String get label => switch (this) {
    _TransactionFilter.all => 'Todas',
    _TransactionFilter.income => 'Receitas',
    _TransactionFilter.expense => 'Despesas',
    _TransactionFilter.transfer => 'Transferências',
  };

  bool accepts(FinancialTransaction item) => switch (this) {
    _TransactionFilter.all => true,
    _TransactionFilter.income => item.type == TransactionType.income,
    _TransactionFilter.expense =>
      item.type == TransactionType.expense ||
          item.type == TransactionType.cardPurchase,
    _TransactionFilter.transfer =>
      item.type == TransactionType.transfer ||
          item.type == TransactionType.cardStatementPayment,
  };
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  var _filter = _TransactionFilter.all;
  var _query = '';
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final privacyHidden = ref.watch(privacyModeProvider);
    return transactions.when(
      loading: () =>
          const PollarLoadingState(message: 'Carregando transações…'),
      error: (error, stackTrace) => PollarErrorState(
        title: 'Não foi possível carregar as transações',
        message: 'Tente carregar novamente. Nenhum lançamento foi alterado.',
        actionLabel: 'Carregar transações novamente',
        onRetry: () => ref.invalidate(transactionsProvider),
      ),
      data: (data) => _buildContent(context, data, privacyHidden),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TransactionsState data,
    bool privacyHidden,
  ) {
    final query = _query.trim().toLowerCase();
    final filtered = data.items
        .where(_filter.accepts)
        .where(
          (item) =>
              query.isEmpty ||
              item.description.toLowerCase().contains(query) ||
              (item.category?.toLowerCase().contains(query) ?? false),
        )
        .toList(growable: false);
    final compact =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    final showDetail =
        MediaQuery.sizeOf(context).width >= PollarBreakpoints.expandedMin;
    final selected = _findById(data.items, _selectedId);

    if (compact) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: PollarSizes.contentMax),
          child: ListView(
            padding: const EdgeInsets.all(PollarSpacing.x4),
            children: [
              _TransactionsHeader(
                compact: true,
                onCreate: () => _openCreate(context),
              ),
              const SizedBox(height: PollarSpacing.x5),
              _FilterBar(
                filter: _filter,
                onFilterChanged: (value) => setState(() => _filter = value),
                onQueryChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: PollarSpacing.x5),
              if (data.items.isEmpty)
                EmptyState(
                  icon: LucideIcons.arrowLeftRight,
                  title: 'Nenhuma transação ainda',
                  message: 'Registre uma receita, despesa ou transferência para iniciar seu histórico.',
                  action: PollarButton(
                    label: 'Registrar primeira transação',
                    leadingIcon: LucideIcons.plus,
                    onPressed: () => _openCreate(context),
                  ),
                )
              else if (filtered.isEmpty)
                const EmptyState(
                  icon: LucideIcons.listFilter,
                  title: 'Nenhuma transação encontrada',
                  message: 'Ajuste a busca ou os filtros para consultar outros lançamentos.',
                )
              else
                _CompactLedger(
                  items: filtered,
                  accounts: data.accounts,
                  privacyHidden: privacyHidden,
                  onSelected: (item) => _openCompactDetail(context, data, item),
                ),
              const SizedBox(height: PollarSpacing.x8),
            ],
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PollarSizes.contentMax),
        child: Padding(
          padding: const EdgeInsets.all(PollarSpacing.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TransactionsHeader(
                compact: false,
                onCreate: () => _openCreate(context),
              ),
              const SizedBox(height: PollarSpacing.x5),
              _FilterBar(
                filter: _filter,
                onFilterChanged: (value) => setState(() => _filter = value),
                onQueryChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: PollarSpacing.x5),
              Expanded(
                child: data.items.isEmpty
                    ? SingleChildScrollView(
                        child: EmptyState(
                          icon: LucideIcons.arrowLeftRight,
                          title: 'Nenhuma transação ainda',
                          message: 'Registre uma receita, despesa ou transferência para iniciar seu histórico.',
                          action: PollarButton(
                            label: 'Registrar primeira transação',
                            leadingIcon: LucideIcons.plus,
                            onPressed: () => _openCreate(context),
                          ),
                        ),
                      )
                    : filtered.isEmpty
                    ? const SingleChildScrollView(
                        child: EmptyState(
                          icon: LucideIcons.listFilter,
                          title: 'Nenhuma transação encontrada',
                          message: 'Ajuste a busca ou os filtros para consultar outros lançamentos.',
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _DesktopLedger(
                              items: filtered,
                              accounts: data.accounts,
                              privacyHidden: privacyHidden,
                              selectedId: showDetail ? _selectedId : null,
                              onSelected: (item) {
                                if (showDetail) {
                                  setState(() => _selectedId = item.id);
                                } else {
                                  _openCompactDetail(context, data, item);
                                }
                              },
                            ),
                          ),
                          if (showDetail && selected != null) ...[
                            const SizedBox(width: PollarSpacing.x5),
                            SizedBox(
                              width: PollarSizes.contextPanel,
                              child: _TransactionDetail(
                                transaction: selected,
                                accounts: data.accounts,
                                privacyHidden: privacyHidden,
                                onClose: () =>
                                    setState(() => _selectedId = null),
                                onCancel: selected.isCanceled
                                    ? null
                                    : () => _confirmCancel(context, selected),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final message = await context.push<String>('/transactions/new');
    if (message != null && context.mounted) {
      showPollarToast(context, message: message);
    }
  }

  Future<void> _openCompactDetail(
    BuildContext context,
    TransactionsState data,
    FinancialTransaction transaction,
  ) async {
    await showPollarAdaptiveModal<void>(
      context: context,
      title: transaction.description,
      description: transaction.type.label,
      icon: transaction.type.kind == TransactionKind.income
          ? LucideIcons.arrowUpRight
          : transaction.type.kind == TransactionKind.transfer
          ? LucideIcons.arrowLeftRight
          : LucideIcons.arrowDownLeft,
      content: (_) => _DetailFields(
        transaction: transaction,
        accounts: data.accounts,
        privacyHidden: ref.read(privacyModeProvider),
        showAmount: true,
      ),
      actions: (modalContext) => [
        if (!transaction.isCanceled)
          PollarButton(
            label: 'Cancelar transação',
            variant: PollarButtonVariant.danger,
            size: PollarControlSize.prominent,
            onPressed: () async {
              Navigator.pop(modalContext);
              await _confirmCancel(context, transaction);
            },
          ),
        PollarButton(
          label: 'Fechar detalhes',
          variant: PollarButtonVariant.secondary,
          size: PollarControlSize.prominent,
          onPressed: () => Navigator.pop(modalContext),
        ),
      ],
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    FinancialTransaction transaction,
  ) async {
    await showPollarAdaptiveModal<void>(
      context: context,
      title: 'Cancelar ${transaction.description}?',
      description: 'O lançamento continuará no histórico, mas deixará de afetar os saldos confirmado e projetado.',
      tone: PollarModalTone.danger,
      icon: LucideIcons.x,
      actions: (modalContext) => [
        PollarButton(
          label: 'Manter transação',
          variant: PollarButtonVariant.secondary,
          onPressed: () => Navigator.pop(modalContext),
        ),
        PollarButton(
          label: 'Cancelar transação',
          variant: PollarButtonVariant.danger,
          onPressed: () async {
            try {
              await ref
                  .read(transactionsProvider.notifier)
                  .cancel(transaction.id);
              if (!modalContext.mounted) return;
              Navigator.pop(modalContext);
              if (context.mounted) {
                showPollarToast(context, message: 'Transação cancelada.');
              }
            } catch (_) {
              if (context.mounted) {
                showPollarToast(
                  context,
                  tone: PollarStatusTone.danger,
                  message:
                      'Não foi possível cancelar a transação. Tente novamente.',
                );
              }
            }
          },
        ),
      ],
    );
  }
}

class _TransactionsHeader extends StatelessWidget {
  const _TransactionsHeader({required this.compact, required this.onCreate});

  final bool compact;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text('Transações', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: PollarSpacing.x2),
        ],
        Text(
          'Receitas, despesas e transferências com impacto financeiro explícito.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: context.pollar.textSecondary),
        ),
      ],
    );
    final action = PollarButton(
      label: 'Nova transação',
      leadingIcon: LucideIcons.plus,
      fullWidth: compact,
      onPressed: onCreate,
    );
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: PollarSpacing.x4),
          action,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: PollarSpacing.x6),
        action,
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.onFilterChanged,
    required this.onQueryChanged,
  });

  final _TransactionFilter filter;
  final ValueChanged<_TransactionFilter> onFilterChanged;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final search = SizedBox(
      width: 280,
      child: PollarTextField(
        key: const Key('transaction-search'),
        label: 'Buscar transações',
        hint: 'Descrição ou categoria',
        leadingIcon: LucideIcons.search,
        onChanged: onQueryChanged,
      ),
    );
    final filters = Wrap(
      spacing: PollarSpacing.x2,
      runSpacing: PollarSpacing.x2,
      children: [
        for (final value in _TransactionFilter.values)
          FilterChip(
            key: ValueKey('filter-${value.name}'),
            label: Text(value.label),
            selected: filter == value,
            selectedColor: context.pollar.primarySoft,
            checkmarkColor: context.pollar.primary,
            backgroundColor: context.pollar.canvas,
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: filter == value
                  ? context.pollar.primary
                  : context.pollar.textSecondary,
            ),
            side: BorderSide(
              color: filter == value
                  ? context.pollar.primary
                  : context.pollar.borderStrong,
            ),
            onSelected: (_) => onFilterChanged(value),
          ),
      ],
    );
    if (MediaQuery.sizeOf(context).width < PollarBreakpoints.expandedMin) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: double.infinity, child: search),
          const SizedBox(height: PollarSpacing.x3),
          filters,
        ],
      );
    }
    return Row(
      children: [
        search,
        const SizedBox(width: PollarSpacing.x4),
        Expanded(child: filters),
      ],
    );
  }
}

class _CompactLedger extends StatelessWidget {
  const _CompactLedger({
    required this.items,
    required this.accounts,
    required this.privacyHidden,
    required this.onSelected,
  });

  final List<FinancialTransaction> items;
  final List<TransactionAccountReference> accounts;
  final bool privacyHidden;
  final ValueChanged<FinancialTransaction> onSelected;

  @override
  Widget build(BuildContext context) {
    final groups = <DateTime, List<FinancialTransaction>>{};
    for (final item in items) {
      groups
          .putIfAbsent(DateUtils.dateOnly(item.occurredAt), () => [])
          .add(item);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: PollarSpacing.x3,
              bottom: PollarSpacing.x2,
            ),
            child: Text(
              _dayLabel(entry.key),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          PollarCard(
            padding: PollarCardPadding.none,
            child: Column(
              children: [
                for (final (index, item) in entry.value.indexed) ...[
                  if (index > 0)
                    Divider(height: 1, color: context.pollar.border),
                  _TransactionRow(
                    transaction: item,
                    accounts: accounts,
                    privacyHidden: privacyHidden,
                    onTap: () => onSelected(item),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DesktopLedger extends StatelessWidget {
  const _DesktopLedger({
    required this.items,
    required this.accounts,
    required this.privacyHidden,
    required this.selectedId,
    required this.onSelected,
  });

  final List<FinancialTransaction> items;
  final List<TransactionAccountReference> accounts;
  final bool privacyHidden;
  final String? selectedId;
  final ValueChanged<FinancialTransaction> onSelected;

  @override
  Widget build(BuildContext context) => PollarCard(
    padding: PollarCardPadding.none,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PollarSpacing.x4,
            vertical: PollarSpacing.x3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'LANÇAMENTO',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.pollar.textMuted,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                'VALOR E ESTADO',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.pollar.textMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: context.pollar.border),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: context.pollar.border),
            itemBuilder: (context, index) {
              final item = items[index];
              return _TransactionRow(
                transaction: item,
                accounts: accounts,
                privacyHidden: privacyHidden,
                selected: selectedId == item.id,
                onTap: () => onSelected(item),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.accounts,
    required this.privacyHidden,
    required this.onTap,
    this.selected = false,
  });

  final FinancialTransaction transaction;
  final List<TransactionAccountReference> accounts;
  final bool privacyHidden;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => TransactionTile(
    title: transaction.description,
    category: transaction.category ?? transaction.type.label,
    account: _accountName(accounts, transaction.accountId),
    date: DateFormat('dd MMM', 'pt_BR').format(transaction.occurredAt),
    amount: transaction.displayAmount,
    kind: transaction.type.kind,
    status: transaction.status.label,
    statusTone: transaction.status.tone,
    statusIcon: transaction.status.icon,
    privacyHidden: privacyHidden,
    selected: selected,
    onTap: onTap,
  );
}

class _TransactionDetail extends StatelessWidget {
  const _TransactionDetail({
    required this.transaction,
    required this.accounts,
    required this.privacyHidden,
    required this.onClose,
    required this.onCancel,
  });

  final FinancialTransaction transaction;
  final List<TransactionAccountReference> accounts;
  final bool privacyHidden;
  final VoidCallback onClose;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) => PollarCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Detalhes da transação',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            PollarIconButton(
              icon: LucideIcons.x,
              label: 'Fechar detalhes',
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: PollarSpacing.x5),
        Text(
          transaction.description,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: PollarSpacing.x2),
        Align(
          alignment: Alignment.centerLeft,
          child: StatusBadge(
            label: transaction.status.label,
            tone: transaction.status.tone,
            icon: transaction.status.icon,
          ),
        ),
        const SizedBox(height: PollarSpacing.x6),
        PrivacyAmount(
          transaction.displayAmount,
          hidden: privacyHidden,
          showSign: transaction.type == TransactionType.income,
          colorBySign: transaction.type == TransactionType.income,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: PollarSpacing.x5),
        Divider(height: 1, color: context.pollar.border),
        const SizedBox(height: PollarSpacing.x5),
        Expanded(
          child: SingleChildScrollView(
            child: _DetailFields(
              transaction: transaction,
              accounts: accounts,
              privacyHidden: privacyHidden,
            ),
          ),
        ),
        if (onCancel != null) ...[
          const SizedBox(height: PollarSpacing.x5),
          PollarButton(
            label: 'Cancelar transação',
            variant: PollarButtonVariant.danger,
            onPressed: onCancel,
          ),
        ],
      ],
    ),
  );
}

class _DetailFields extends StatelessWidget {
  const _DetailFields({
    required this.transaction,
    required this.accounts,
    required this.privacyHidden,
    this.showAmount = false,
  });

  final FinancialTransaction transaction;
  final List<TransactionAccountReference> accounts;
  final bool privacyHidden;
  final bool showAmount;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (showAmount) ...[
        PrivacyAmount(
          transaction.displayAmount,
          hidden: privacyHidden,
          showSign: transaction.type == TransactionType.income,
          colorBySign: transaction.type == TransactionType.income,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: PollarSpacing.x4),
        Divider(height: 1, color: context.pollar.border),
        const SizedBox(height: PollarSpacing.x4),
      ],
      _DetailLine(label: 'Tipo', value: transaction.type.label),
      _DetailLine(
        label: transaction.counterAccountId == null ? 'Conta' : 'Origem',
        value: _accountName(accounts, transaction.accountId),
      ),
      if (transaction.counterAccountId case final counterId?)
        _DetailLine(label: 'Destino', value: _accountName(accounts, counterId)),
      _DetailLine(
        label: 'Data',
        value: DateFormat.yMMMMd('pt_BR').format(transaction.occurredAt),
      ),
      if (transaction.category case final category?)
        _DetailLine(label: 'Categoria', value: category),
      if (transaction.note case final note?)
        _DetailLine(label: 'Observação', value: note),
    ],
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: PollarSpacing.x4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.pollar.textMuted),
        ),
        const SizedBox(height: PollarSpacing.x1),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

FinancialTransaction? _findById(List<FinancialTransaction> items, String? id) {
  if (id == null) return null;
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}

String _accountName(List<TransactionAccountReference> accounts, String id) {
  for (final account in accounts) {
    if (account.id == id) return account.name;
  }
  return 'Conta não disponível';
}

String _dayLabel(DateTime date) {
  final today = DateUtils.dateOnly(DateTime.now());
  if (date == today) return 'Hoje';
  if (date == today.subtract(const Duration(days: 1))) return 'Ontem';
  return DateFormat.yMMMMd('pt_BR').format(date);
}

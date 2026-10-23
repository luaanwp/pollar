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
import '../../../shared/presentation/pollar_motion.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_modal.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/pollar_text_field.dart';
import '../../../shared/presentation/pollar_form_controls.dart';
import '../../../shared/presentation/pollar_toast.dart';
import '../../../shared/presentation/privacy_amount.dart';
import '../../../shared/presentation/money_text.dart';
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
  final _searchController = TextEditingController();
  final _controlsKey = GlobalKey(debugLabel: 'transaction-controls');
  final _searchKey = GlobalKey(debugLabel: 'transaction-search-field');
  var _filter = _TransactionFilter.all;
  var _query = '';
  String? _selectedId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final today = DateUtils.dateOnly(ref.watch(transactionClockProvider)());
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
    final compactWindow =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    final selected = _findById(filtered, _selectedId);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PollarSizes.contentMax),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gutter = compactWindow ? PollarSpacing.x4 : PollarSpacing.x6;
            final width = constraints.maxWidth - gutter * 2;
            final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
            final scrollLayout =
                width < 600 || constraints.maxHeight < 500 || largeText;
            final showDetail = !scrollLayout && width >= 1020;
            void clear() {
              _searchController.clear();
              setState(() {
                _query = '';
                _filter = _TransactionFilter.all;
              });
            }

            final controls = Column(
              key: _controlsKey,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TransactionsHeader(
                  compact: compactWindow,
                  onCreate: () => _openCreate(context),
                ),
                const SizedBox(height: PollarSpacing.x4),
                _FilterBar(
                  controller: _searchController,
                  searchKey: _searchKey,
                  filter: _filter,
                  count: filtered.length,
                  onClear:
                      _query.isNotEmpty || _filter != _TransactionFilter.all
                      ? clear
                      : null,
                  onFilterChanged: (value) => setState(() => _filter = value),
                  onQueryChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: PollarSpacing.x4),
              ],
            );
            Widget? empty;
            if (data.items.isEmpty) {
              empty = EmptyState(
                icon: LucideIcons.arrowLeftRight,
                title: 'Nenhuma transação ainda',
                message: 'Registre uma receita, despesa ou transferência para iniciar seu histórico.',
                action: PollarButton(
                  label: 'Registrar primeira transação',
                  adaptiveHeight: true,
                  leadingIcon: LucideIcons.plus,
                  onPressed: () => _openCreate(context),
                ),
              );
            } else if (filtered.isEmpty) {
              empty = const EmptyState(
                icon: LucideIcons.listFilter,
                title: 'Nenhuma transação encontrada',
                message: 'Ajuste a busca ou os filtros para consultar outros lançamentos.',
              );
            }
            if (scrollLayout) {
              return ListView(
                key: const PageStorageKey('transaction-scroll'),
                padding: EdgeInsets.all(gutter),
                children: [
                  controls,
                  if (empty != null)
                    empty
                  else
                    _CompactLedger(
                      items: filtered,
                      accounts: data.accounts,
                      privacyHidden: privacyHidden,
                      today: today,
                      onSelected: (item) =>
                          _openCompactDetail(context, data, item),
                    ),
                  const SizedBox(height: PollarSpacing.x8),
                ],
              );
            }
            return Padding(
              padding: EdgeInsets.all(gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  controls,
                  Expanded(
                    child: empty != null
                        ? SingleChildScrollView(child: empty)
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
                                        : () =>
                                              _confirmCancel(context, selected),
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
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
      content: (modalContext) {
        final fields = Consumer(
          builder: (context, modalRef, child) => _DetailFields(
            transaction: transaction,
            accounts: data.accounts,
            privacyHidden: modalRef.watch(privacyModeProvider),
            showAmount: true,
          ),
        );
        if (MediaQuery.sizeOf(modalContext).width <
            PollarBreakpoints.mediumMin) {
          return fields;
        }
        // AlertDialog asks for intrinsic dimensions. A bounded scroll viewport
        // keeps responsive amount measurement out of that intrinsic pass.
        final height =
            MediaQuery.sizeOf(modalContext).height -
            MediaQuery.viewInsetsOf(modalContext).bottom;
        return SizedBox(
          width: 440,
          height: (height * 0.45).clamp(120.0, 440.0),
          child: SingleChildScrollView(child: fields),
        );
      },
      actions: (modalContext) => [
        if (!transaction.isCanceled)
          PollarButton(
            label: 'Cancelar transação',
            adaptiveHeight: true,
            variant: PollarButtonVariant.danger,
            size: PollarControlSize.prominent,
            onPressed: () async {
              Navigator.pop(modalContext);
              await _confirmCancel(context, transaction);
            },
          ),
        PollarButton(
          label: 'Fechar detalhes',
          adaptiveHeight: true,
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
          adaptiveHeight: true,
          variant: PollarButtonVariant.secondary,
          onPressed: () => Navigator.pop(modalContext),
        ),
        PollarButton(
          label: 'Cancelar transação',
          variant: PollarButtonVariant.danger,
          adaptiveHeight: true,
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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked =
          compact ||
          constraints.maxWidth < 760 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.3;
      final action = PollarButton(
        label: 'Nova transação',
        adaptiveHeight: true,
        leadingIcon: LucideIcons.plus,
        fullWidth: stacked,
        onPressed: onCreate,
      );
      if (compact) return action;
      final title = Semantics(
        header: true,
        child: Text(
          'Transações',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      );
      if (stacked) {
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
        children: [
          Expanded(child: title),
          const SizedBox(width: PollarSpacing.x6),
          action,
        ],
      );
    },
  );
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.controller,
    required this.searchKey,
    required this.filter,
    required this.onFilterChanged,
    required this.onQueryChanged,
    required this.count,
    this.onClear,
  });
  final _TransactionFilter filter;
  final TextEditingController controller;
  final GlobalKey searchKey;
  final ValueChanged<_TransactionFilter> onFilterChanged;
  final ValueChanged<String> onQueryChanged;
  final int count;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
      final search = KeyedSubtree(
        key: searchKey,
        child: PollarTextField(
          key: const Key('transaction-search'),
          controller: controller,
          label: 'Buscar transações',
          hint: 'Descrição ou categoria',
          leadingIcon: LucideIcons.search,
          onChanged: onQueryChanged,
        ),
      );
      final types = PollarSelect<_TransactionFilter>(
        key: ValueKey('transaction-type-${filter.name}'),
        label: 'Tipo',
        itemHeight: null,
        initialValue: filter,
        options: [
          for (final value in _TransactionFilter.values)
            PollarSelectOption(value: value, label: value.label),
        ],
        onChanged: (value) {
          if (value != null) onFilterChanged(value);
        },
      );
      Widget choices;
      if (constraints.maxWidth >= 960 && !largeText) {
        choices = Row(
          children: [
            SizedBox(width: 280, child: search),
            const SizedBox(width: PollarSpacing.x4),
            Expanded(
              child: Wrap(
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
                      labelStyle: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(
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
              ),
            ),
          ],
        );
      } else if (constraints.maxWidth >= 600 && !largeText) {
        choices = Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: PollarSpacing.x4),
            SizedBox(width: 224, child: types),
          ],
        );
      } else {
        choices = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            search,
            const SizedBox(height: PollarSpacing.x3),
            types,
          ],
        );
      }
      final countLabel = Semantics(
        liveRegion: true,
        child: Text(
          '$count ${count == 1 ? 'transação' : 'transações'}',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.pollar.textSecondary),
        ),
      );
      final clear = onClear == null
          ? null
          : PollarButton(
              label: 'Limpar busca e filtro',
              adaptiveHeight: true,
              variant: PollarButtonVariant.ghost,
              size: PollarControlSize.compact,
              onPressed: onClear,
            );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          choices,
          const SizedBox(height: PollarSpacing.x2),
          if (largeText && clear != null) ...[
            countLabel,
            Align(alignment: Alignment.centerRight, child: clear),
          ] else
            Row(
              children: [
                Expanded(child: countLabel),
                ?clear,
              ],
            ),
        ],
      );
    },
  );
}

class _CompactLedger extends StatelessWidget {
  const _CompactLedger({
    required this.items,
    required this.accounts,
    required this.privacyHidden,
    required this.onSelected,
    required this.today,
  });

  final List<FinancialTransaction> items;
  final List<TransactionAccountReference> accounts;
  final bool privacyHidden;
  final ValueChanged<FinancialTransaction> onSelected;
  final DateTime today;

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
              _dayLabel(entry.key, today),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          PollarCard(
            variant: PollarCardVariant.flat,
            padding: PollarCardPadding.none,
            child: Column(
              children: [
                for (final (index, item) in entry.value.indexed) ...[
                  if (index > 0)
                    Divider(height: 1, color: context.pollar.border),
                  PollarReveal(
                    key: ValueKey(item.id),
                    identity: item.id,
                    index: index,
                    onArrival: true,
                    child: _TransactionRow(
                      transaction: item,
                      accounts: accounts,
                      privacyHidden: privacyHidden,
                      onTap: () => onSelected(item),
                    ),
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
              return PollarReveal(
                key: ValueKey(item.id),
                identity: item.id,
                index: index,
                onArrival: true,
                child: _TransactionRow(
                  transaction: item,
                  accounts: accounts,
                  privacyHidden: privacyHidden,
                  selected: selectedId == item.id,
                  onTap: () => onSelected(item),
                ),
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
    reflowContent: true,
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
              child: Semantics(
                header: true,
                child: Text(
                  'Detalhes da transação',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            PollarIconButton(
              icon: LucideIcons.x,
              label: 'Fechar detalhes',
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: PollarSpacing.x4),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: PollarSpacing.x3),
                _DetailFields(
                  transaction: transaction,
                  accounts: accounts,
                  privacyHidden: privacyHidden,
                  showAmount: true,
                ),
              ],
            ),
          ),
        ),
        if (onCancel != null) ...[
          const SizedBox(height: PollarSpacing.x3),
          PollarButton(
            label: 'Cancelar transação',
            adaptiveHeight: true,
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
        Align(
          alignment: Alignment.centerLeft,
          child: StatusBadge(
            label: transaction.status.label,
            tone: transaction.status.tone,
            icon: transaction.status.icon,
          ),
        ),
        const SizedBox(height: PollarSpacing.x3),
        PrivacyAmount(
          transaction.displayAmount,
          hidden: privacyHidden,
          allowWrap: true,
          reserveLayout: true,
          semantic: _amountMeaning(transaction.type),
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

String _dayLabel(DateTime date, DateTime today) {
  if (date == today) return 'Hoje';
  if (date == today.subtract(const Duration(days: 1))) return 'Ontem';
  return DateFormat.yMMMMd('pt_BR').format(date);
}

MoneySemantic _amountMeaning(TransactionType type) => switch (type) {
  TransactionType.income => MoneySemantic.income,
  TransactionType.expense ||
  TransactionType.cardPurchase => MoneySemantic.expense,
  TransactionType.transfer ||
  TransactionType.cardStatementPayment => MoneySemantic.neutral,
};

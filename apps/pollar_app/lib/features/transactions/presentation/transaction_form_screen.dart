import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../core/ledger/balance_rules.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/currency_input.dart';
import '../../../shared/presentation/pollar_banner.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_card.dart';
import '../../../shared/presentation/pollar_form_controls.dart';
import '../../../shared/presentation/pollar_modal.dart';
import '../../../shared/presentation/pollar_states.dart';
import '../../../shared/presentation/pollar_text_field.dart';
import '../../../shared/presentation/status_badge.dart';
import '../application/transaction_account_catalog.dart';
import '../domain/financial_transaction.dart';
import 'transactions_controller.dart';

enum _EntryKind { expense, income, transfer }

extension on _EntryKind {
  String get label => switch (this) {
    _EntryKind.expense => 'Despesa',
    _EntryKind.income => 'Receita',
    _EntryKind.transfer => 'Transferência',
  };
}

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();
  var _kind = _EntryKind.expense;
  var _status = TransactionStatus.compensado;
  var _date = DateUtils.dateOnly(DateTime.now());
  String? _accountId;
  String? _counterAccountId;
  Money? _amount;
  var _saving = false;
  var _dirty = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_markDirty);
    _categoryController.addListener(_markDirty);
    _noteController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_dirty && mounted) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsProvider);
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: state.when(
        loading: () => const PollarLoadingState(message: 'Carregando contas…'),
        error: (error, stackTrace) => PollarErrorState(
          title: 'Não foi possível preparar o lançamento',
          message: 'Tente carregar novamente antes de registrar a transação.',
          actionLabel: 'Carregar dados novamente',
          onRetry: () => ref.invalidate(transactionsProvider),
        ),
        data: (data) => _buildForm(context, data.accounts),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<TransactionAccountReference> allAccounts,
  ) {
    final compact =
        MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin;
    final accounts = allAccounts
        .where((account) => !account.isArchived)
        .where(
          (account) => _kind == _EntryKind.expense || !account.isCreditCard,
        )
        .toList(growable: false);
    final transferAccounts = accounts
        .where(
          (account) =>
              !account.isCreditCard &&
              account.id != _accountId &&
              (_accountId == null ||
                  account.currency ==
                      accounts
                          .firstWhere((source) => source.id == _accountId)
                          .currency),
        )
        .toList(growable: false);
    final selectedAccount = _accountId == null
        ? null
        : accounts.firstWhere((account) => account.id == _accountId);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: EdgeInsets.all(
            compact ? PollarSpacing.x4 : PollarSpacing.x6,
          ),
          children: [
            _FormHeader(kind: _kind, onBack: _requestBack),
            const SizedBox(height: PollarSpacing.x6),
            if (accounts.isEmpty)
              _NoAccounts(onOpenAccounts: () => context.go('/accounts'))
            else
              PollarCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Movimento',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: PollarSpacing.x5),
                      PollarSelect<_EntryKind>(
                        key: const Key('transaction-kind'),
                        label: 'Tipo de transação',
                        initialValue: _kind,
                        options: [
                          for (final kind in _EntryKind.values)
                            PollarSelectOption(value: kind, label: kind.label),
                        ],
                        onChanged: (kind) {
                          if (kind == null) return;
                          setState(() {
                            _dirty = true;
                            _kind = kind;
                            _accountId = null;
                            _counterAccountId = null;
                            _amount = null;
                            _error = null;
                          });
                        },
                      ),
                      const SizedBox(height: PollarSpacing.x5),
                      PollarTextField(
                        key: const Key('transaction-description'),
                        label: 'Descrição',
                        hint: _kind == _EntryKind.income
                            ? 'Salário'
                            : _kind == _EntryKind.transfer
                            ? 'Reserva mensal'
                            : 'Mercado do bairro',
                        controller: _descriptionController,
                        leadingIcon: LucideIcons.receiptText,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Informe o que originou a transação.'
                            : null,
                      ),
                      const SizedBox(height: PollarSpacing.x5),
                      CurrencyInput(
                        key: ValueKey(
                          'transaction-amount-${_kind.name}-${selectedAccount?.currency.code}',
                        ),
                        label: 'Valor',
                        currency:
                            selectedAccount?.currency ??
                            accounts.first.currency,
                        onChanged: (value) {
                          _amount = value;
                          _markDirty();
                        },
                        validator: (value) => value == null || !value.isPositive
                            ? 'Informe um valor maior que zero.'
                            : null,
                      ),
                      const SizedBox(height: PollarSpacing.x8),
                      Text(
                        _kind == _EntryKind.transfer
                            ? 'Origem e destino'
                            : 'Classificação',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: PollarSpacing.x5),
                      PollarSelect<String>(
                        key: ValueKey('source-${_kind.name}'),
                        label: _kind == _EntryKind.transfer
                            ? 'Conta de origem'
                            : 'Conta ou cartão',
                        initialValue: _accountId,
                        options: [
                          for (final account in accounts)
                            PollarSelectOption(
                              value: account.id,
                              label: account.name,
                            ),
                        ],
                        onChanged: (value) => setState(() {
                          _dirty = true;
                          final previous = _accountId == null
                              ? null
                              : accounts
                                    .firstWhere(
                                      (account) => account.id == _accountId,
                                    )
                                    .currency;
                          _accountId = value;
                          final next = value == null
                              ? null
                              : accounts
                                    .firstWhere(
                                      (account) => account.id == value,
                                    )
                                    .currency;
                          if (previous != next) _amount = null;
                          if (_counterAccountId == value) {
                            _counterAccountId = null;
                          }
                        }),
                        validator: (value) => value == null
                            ? 'Selecione a conta desta transação.'
                            : null,
                      ),
                      if (_kind == _EntryKind.transfer) ...[
                        const SizedBox(height: PollarSpacing.x5),
                        PollarSelect<String>(
                          key: ValueKey('destination-$_accountId'),
                          label: 'Conta de destino',
                          initialValue: _counterAccountId,
                          options: [
                            for (final account in transferAccounts)
                              PollarSelectOption(
                                value: account.id,
                                label: account.name,
                              ),
                          ],
                          onChanged: (value) => setState(() {
                            _dirty = true;
                            _counterAccountId = value;
                          }),
                          validator: (value) => value == null
                              ? 'Selecione uma conta de destino diferente.'
                              : null,
                        ),
                      ] else ...[
                        const SizedBox(height: PollarSpacing.x5),
                        PollarTextField(
                          key: const Key('transaction-category'),
                          label: 'Categoria (opcional)',
                          hint: _kind == _EntryKind.income
                              ? 'Renda'
                              : 'Alimentação',
                          controller: _categoryController,
                        ),
                      ],
                      const SizedBox(height: PollarSpacing.x5),
                      _DateAndStatus(
                        date: _date,
                        status: _status,
                        onChooseDate: _chooseDate,
                        onStatusChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _dirty = true;
                              _status = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: PollarSpacing.x5),
                      PollarTextField(
                        key: const Key('transaction-note'),
                        label: 'Observação (opcional)',
                        hint: 'Detalhes úteis para consultar depois',
                        controller: _noteController,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: PollarSpacing.x5),
                        PollarBanner(
                          tone: PollarStatusTone.danger,
                          title: 'A transação não foi salva',
                          message: _error!,
                        ),
                      ],
                      const SizedBox(height: PollarSpacing.x6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PollarButton(
                          label: 'Salvar transação',
                          leadingIcon: LucideIcons.save,
                          loading: _saving,
                          fullWidth: compact,
                          onPressed: _saving ? null : () => _save(allAccounts),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: PollarSpacing.x8),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'Escolher data da transação',
      cancelText: 'Cancelar',
      confirmText: 'Escolher data',
    );
    if (selected != null) {
      setState(() {
        _dirty = true;
        _date = DateUtils.dateOnly(selected);
      });
    }
  }

  Future<void> _save(List<TransactionAccountReference> accounts) async {
    if (!_formKey.currentState!.validate()) return;
    final sourceId = _accountId;
    final amount = _amount;
    if (sourceId == null || amount == null) return;
    final source = accounts.singleWhere((account) => account.id == sourceId);
    final type = switch (_kind) {
      _EntryKind.income => TransactionType.income,
      _EntryKind.expense =>
        source.isCreditCard
            ? TransactionType.cardPurchase
            : TransactionType.expense,
      _EntryKind.transfer => TransactionType.transfer,
    };

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(transactionsProvider.notifier)
          .create(
            FinancialTransaction(
              id: const Uuid().v4(),
              description: _descriptionController.text,
              type: type,
              status: _status,
              amount: amount,
              accountId: sourceId,
              counterAccountId: _kind == _EntryKind.transfer
                  ? _counterAccountId
                  : null,
              occurredAt: _date,
              category: _kind == _EntryKind.transfer
                  ? null
                  : _categoryController.text,
              note: _noteController.text,
            ),
          );
      if (mounted) {
        setState(() => _dirty = false);
        await Future<void>.delayed(Duration.zero);
        if (!mounted) return;
        context.pop('Transação salva.');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Revise as contas e o valor antes de tentar novamente.';
      });
    }
  }

  Future<void> _confirmDiscard() async {
    final discard = await showPollarAdaptiveModal<bool>(
      context: context,
      title: 'Descartar transação não salva?',
      description: 'Os dados preenchidos serão perdidos. A transação ainda não alterou nenhum saldo.',
      tone: PollarModalTone.danger,
      icon: LucideIcons.trash2,
      actions: (modalContext) => [
        PollarButton(
          label: 'Continuar preenchendo',
          variant: PollarButtonVariant.secondary,
          onPressed: () => Navigator.pop(modalContext, false),
        ),
        PollarButton(
          label: 'Descartar transação',
          variant: PollarButtonVariant.danger,
          onPressed: () => Navigator.pop(modalContext, true),
        ),
      ],
    );
    if (discard == true && mounted) {
      setState(() => _dirty = false);
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      context.pop();
    }
  }

  void _requestBack() {
    if (_dirty) {
      _confirmDiscard();
    } else {
      context.pop();
    }
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.kind, required this.onBack});

  final _EntryKind kind;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      PollarIconButton(
        icon: LucideIcons.arrowLeft,
        label: 'Voltar para transações',
        outlined: true,
        onPressed: onBack,
      ),
      const SizedBox(width: PollarSpacing.x4),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nova transação',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: PollarSpacing.x2),
            Text(
              'Registre ${kind.label.toLowerCase()} com valor exato, conta e estado.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.pollar.textSecondary),
            ),
          ],
        ),
      ),
    ],
  );
}

class _NoAccounts extends StatelessWidget {
  const _NoAccounts({required this.onOpenAccounts});

  final VoidCallback onOpenAccounts;

  @override
  Widget build(BuildContext context) => PollarCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PollarBanner(
          tone: PollarStatusTone.info,
          title: 'Cadastre uma conta primeiro',
          message: 'Toda transação precisa estar vinculada a uma conta ativa.',
        ),
        const SizedBox(height: PollarSpacing.x5),
        PollarButton(
          label: 'Abrir contas',
          variant: PollarButtonVariant.secondary,
          onPressed: onOpenAccounts,
        ),
      ],
    ),
  );
}

class _DateAndStatus extends StatelessWidget {
  const _DateAndStatus({
    required this.date,
    required this.status,
    required this.onChooseDate,
    required this.onStatusChanged,
  });

  final DateTime date;
  final TransactionStatus status;
  final VoidCallback onChooseDate;
  final ValueChanged<TransactionStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final dateField = Semantics(
      button: true,
      label: 'Data da transação, ${DateFormat.yMMMMd('pt_BR').format(date)}',
      child: InkWell(
        key: const Key('transaction-date'),
        onTap: onChooseDate,
        borderRadius: BorderRadius.circular(PollarRadii.medium),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Data',
            prefixIcon: Icon(LucideIcons.calendarDays, size: 20),
          ),
          child: Text(DateFormat('dd/MM/yyyy').format(date)),
        ),
      ),
    );
    final statusField = PollarSelect<TransactionStatus>(
      key: const Key('transaction-status'),
      label: 'Estado',
      initialValue: status,
      options: [
        for (final value in TransactionStatus.values)
          if (value != TransactionStatus.cancelado)
            PollarSelectOption(value: value, label: _statusLabel(value)),
      ],
      onChanged: onStatusChanged,
    );

    if (MediaQuery.sizeOf(context).width < PollarBreakpoints.mediumMin) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          dateField,
          const SizedBox(height: PollarSpacing.x5),
          statusField,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: dateField),
        const SizedBox(width: PollarSpacing.x4),
        Expanded(child: statusField),
      ],
    );
  }

  String _statusLabel(TransactionStatus value) => switch (value) {
    TransactionStatus.previsto => 'Previsto',
    TransactionStatus.pendente => 'Pendente',
    TransactionStatus.compensado => 'Compensado',
    TransactionStatus.conciliado => 'Conciliado',
    TransactionStatus.cancelado => 'Cancelado',
  };
}

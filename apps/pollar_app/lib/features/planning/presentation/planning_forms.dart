import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/pollar_theme.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../shared/presentation/currency_input.dart';
import '../../../shared/presentation/pollar_button.dart';
import '../../../shared/presentation/pollar_form_controls.dart';
import '../../../shared/presentation/pollar_modal.dart';
import '../../../shared/presentation/pollar_text_field.dart';
import '../application/planning_ledger_source.dart';
import '../domain/budget.dart';
import '../domain/recurring_rule.dart';

Future<bool?> showBudgetForm({
  required BuildContext context,
  required DateTime month,
  required Currency currency,
  required Future<void> Function(Budget budget) onSave,
}) async {
  final key = GlobalKey<_BudgetFormState>();
  final saving = ValueNotifier(false);
  Future<void>? activeSave;
  final result = await showPollarAdaptiveModal<bool>(
    context: context,
    title: 'Novo orçamento',
    description: 'Defina um limite para uma categoria neste mês. O gasto vem das transações registradas.',
    icon: LucideIcons.gauge,
    dismissible: false,
    content: (_) => _BudgetForm(key: key, month: month, currency: currency),
    actions: (modalContext) => [
      ValueListenableBuilder(
        valueListenable: saving,
        builder: (context, isSaving, child) => PollarButton(
          label: 'Cancelar',
          variant: PollarButtonVariant.ghost,
          onPressed: isSaving ? null : () => Navigator.of(modalContext).pop(),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: saving,
        builder: (context, isSaving, child) => PollarButton(
          label: 'Salvar orçamento',
          loading: isSaving,
          onPressed: isSaving
              ? null
              : () async {
                  final budget = key.currentState?.buildBudget();
                  if (budget == null) return;
                  saving.value = true;
                  key.currentState?.setSaveError(null);
                  activeSave = () async {
                    try {
                      await onSave(budget);
                      if (modalContext.mounted) {
                        Navigator.of(modalContext).pop(true);
                      }
                    } catch (_) {
                      key.currentState?.setSaveError(
                        'Não foi possível salvar o orçamento. Revise os dados e tente novamente.',
                      );
                    } finally {
                      saving.value = false;
                    }
                  }();
                  await activeSave;
                },
        ),
      ),
    ],
  );
  await activeSave;
  saving.dispose();
  return result;
}

Future<bool?> showRecurringRuleForm({
  required BuildContext context,
  required List<PlanningAccountReference> accounts,
  required DateTime initialDate,
  required Future<void> Function(RecurringRule rule) onSave,
}) async {
  final key = GlobalKey<_RecurringRuleFormState>();
  final saving = ValueNotifier(false);
  Future<void>? activeSave;
  final result = await showPollarAdaptiveModal<bool>(
    context: context,
    title: 'Novo compromisso recorrente',
    description: 'Crie uma previsão de entrada, pagamento ou assinatura. Nenhuma transação é lançada automaticamente.',
    icon: LucideIcons.repeat2,
    dismissible: false,
    content: (_) => _RecurringRuleForm(
      key: key,
      accounts: accounts,
      initialDate: initialDate,
    ),
    actions: (modalContext) => [
      ValueListenableBuilder(
        valueListenable: saving,
        builder: (context, isSaving, child) => PollarButton(
          label: 'Cancelar',
          variant: PollarButtonVariant.ghost,
          onPressed: isSaving ? null : () => Navigator.of(modalContext).pop(),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: saving,
        builder: (context, isSaving, child) => PollarButton(
          label: 'Salvar compromisso',
          loading: isSaving,
          onPressed: isSaving
              ? null
              : () async {
                  final rule = key.currentState?.buildRule();
                  if (rule == null) return;
                  saving.value = true;
                  key.currentState?.setSaveError(null);
                  activeSave = () async {
                    try {
                      await onSave(rule);
                      if (modalContext.mounted) {
                        Navigator.of(modalContext).pop(true);
                      }
                    } catch (_) {
                      key.currentState?.setSaveError(
                        'Não foi possível salvar o compromisso. Revise os dados e tente novamente.',
                      );
                    } finally {
                      saving.value = false;
                    }
                  }();
                  await activeSave;
                },
        ),
      ),
    ],
  );
  await activeSave;
  saving.dispose();
  return result;
}

class _BudgetForm extends StatefulWidget {
  const _BudgetForm({super.key, required this.month, required this.currency});

  final DateTime month;
  final Currency currency;

  @override
  State<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<_BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _category = TextEditingController();
  final _threshold = TextEditingController(text: '85');
  Money? _limit;
  String? _saveError;

  void setSaveError(String? value) {
    if (mounted) setState(() => _saveError = value);
  }

  @override
  void dispose() {
    _category.dispose();
    _threshold.dispose();
    super.dispose();
  }

  Budget? buildBudget() {
    if (!_formKey.currentState!.validate()) return null;
    return Budget(
      id: const Uuid().v4(),
      category: _category.text,
      month: widget.month,
      limit: _limit!,
      alertThreshold: int.parse(_threshold.text),
    );
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PollarTextField(
          label: 'Categoria',
          controller: _category,
          hint: 'Ex.: Alimentação',
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Informe a categoria acompanhada.'
              : null,
        ),
        const SizedBox(height: PollarSpacing.x4),
        CurrencyInput(
          label: 'Limite mensal',
          currency: widget.currency,
          onChanged: (value) => _limit = value,
          validator: (value) => value?.isPositive == true
              ? null
              : 'Informe um limite maior que zero.',
        ),
        const SizedBox(height: PollarSpacing.x4),
        PollarTextField(
          label: 'Alertar ao atingir (%)',
          controller: _threshold,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            final parsed = int.tryParse(value ?? '');
            return parsed == null || parsed < 1 || parsed > 100
                ? 'Informe um percentual entre 1 e 100.'
                : null;
          },
        ),
        if (_saveError != null) ...[
          const SizedBox(height: PollarSpacing.x3),
          Text(
            _saveError!,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: context.pollar.danger),
          ),
        ],
      ],
    ),
  );
}

class _RecurringRuleForm extends StatefulWidget {
  const _RecurringRuleForm({
    super.key,
    required this.accounts,
    required this.initialDate,
  });

  final List<PlanningAccountReference> accounts;
  final DateTime initialDate;

  @override
  State<_RecurringRuleForm> createState() => _RecurringRuleFormState();
}

class _RecurringRuleFormState extends State<_RecurringRuleForm> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _category = TextEditingController();
  final _reminder = TextEditingController(text: '3');
  late DateTime _dueDate;
  RecurringKind _kind = RecurringKind.expense;
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  PlanningAccountReference? _account;
  Money? _amount;
  String? _saveError;

  void setSaveError(String? value) {
    if (mounted) setState(() => _saveError = value);
  }

  @override
  void initState() {
    super.initState();
    _dueDate = widget.initialDate;
    _account = widget.accounts.firstOrNull;
  }

  @override
  void dispose() {
    _description.dispose();
    _category.dispose();
    _reminder.dispose();
    super.dispose();
  }

  RecurringRule? buildRule() {
    if (!_formKey.currentState!.validate()) return null;
    return RecurringRule(
      id: const Uuid().v4(),
      description: _description.text,
      kind: _kind,
      frequency: _frequency,
      amount: _amount!,
      accountId: _account!.id,
      category: _category.text,
      firstDueDate: _dueDate,
      remindDaysBefore: int.parse(_reminder.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = _account?.currency ?? Currency.brl;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PollarTextField(
            label: 'Descrição',
            controller: _description,
            hint: 'Ex.: Aluguel',
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Informe o nome do compromisso.'
                : null,
          ),
          const SizedBox(height: PollarSpacing.x4),
          PollarSelect<RecurringKind>(
            label: 'Tipo',
            initialValue: _kind,
            options: const [
              PollarSelectOption(
                value: RecurringKind.expense,
                label: 'Pagamento recorrente',
              ),
              PollarSelectOption(
                value: RecurringKind.subscription,
                label: 'Assinatura',
              ),
              PollarSelectOption(
                value: RecurringKind.income,
                label: 'Entrada recorrente',
              ),
            ],
            onChanged: (value) => setState(() => _kind = value ?? _kind),
          ),
          const SizedBox(height: PollarSpacing.x4),
          PollarSelect<PlanningAccountReference>(
            label: 'Conta ou cartão',
            initialValue: _account,
            options: [
              for (final account in widget.accounts)
                PollarSelectOption(value: account, label: account.name),
            ],
            onChanged: (value) => setState(() {
              _account = value;
              _amount = null;
            }),
            validator: (value) => value == null
                ? 'Escolha a conta ou cartão do compromisso.'
                : null,
          ),
          const SizedBox(height: PollarSpacing.x4),
          CurrencyInput(
            key: ValueKey(currency.code),
            label: 'Valor previsto',
            currency: currency,
            onChanged: (value) => _amount = value,
            validator: (value) => value?.isPositive == true
                ? null
                : 'Informe um valor maior que zero.',
          ),
          const SizedBox(height: PollarSpacing.x4),
          PollarTextField(label: 'Categoria (opcional)', controller: _category),
          const SizedBox(height: PollarSpacing.x4),
          PollarSelect<RecurrenceFrequency>(
            label: 'Frequência',
            initialValue: _frequency,
            options: const [
              PollarSelectOption(
                value: RecurrenceFrequency.weekly,
                label: 'Semanal',
              ),
              PollarSelectOption(
                value: RecurrenceFrequency.monthly,
                label: 'Mensal',
              ),
              PollarSelectOption(
                value: RecurrenceFrequency.yearly,
                label: 'Anual',
              ),
            ],
            onChanged: (value) =>
                setState(() => _frequency = value ?? _frequency),
          ),
          const SizedBox(height: PollarSpacing.x4),
          InkWell(
            borderRadius: BorderRadius.circular(PollarRadii.medium),
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Primeiro vencimento',
                suffixIcon: Icon(LucideIcons.calendarDays, size: 20),
              ),
              child: Text(DateFormat('dd/MM/yyyy', 'pt_BR').format(_dueDate)),
            ),
          ),
          const SizedBox(height: PollarSpacing.x4),
          PollarTextField(
            label: 'Lembrar com antecedência (dias)',
            controller: _reminder,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              final parsed = int.tryParse(value ?? '');
              return parsed == null || parsed < 0 || parsed > 30
                  ? 'Informe um prazo entre 0 e 30 dias.'
                  : null;
            },
          ),
          if (_saveError != null) ...[
            const SizedBox(height: PollarSpacing.x3),
            Text(
              _saveError!,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.pollar.danger),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Primeiro vencimento',
      cancelText: 'Cancelar',
      confirmText: 'Escolher data',
    );
    if (selected != null) setState(() => _dueDate = selected);
  }
}

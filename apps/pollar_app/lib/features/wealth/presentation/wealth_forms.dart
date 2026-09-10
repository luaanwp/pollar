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
import '../domain/wealth_asset.dart';
import '../domain/wealth_debt.dart';
import '../domain/wealth_goal.dart';

Future<bool?> showGoalForm({
  required BuildContext context,
  required Currency currency,
  required DateTime now,
  required Future<void> Function(WealthGoal goal) onSave,
  WealthGoal? initial,
}) async {
  final key = GlobalKey<_GoalFormState>();
  return _showProtectedForm<WealthGoal>(
    context: context,
    title: initial == null ? 'Nova meta' : 'Atualizar meta',
    description: 'Registre o alvo e quanto já foi reservado. A meta não movimenta nenhuma conta.',
    icon: LucideIcons.target,
    saveLabel: initial == null ? 'Salvar meta' : 'Atualizar meta',
    failureMessage:
        'Não foi possível salvar a meta. Revise os dados e tente novamente.',
    content: _GoalForm(
      key: key,
      currency: currency,
      now: now,
      initial: initial,
    ),
    buildValue: () => key.currentState?.buildGoal(),
    setError: (message) => key.currentState?.setSaveError(message),
    onSave: onSave,
  );
}

Future<bool?> showAssetForm({
  required BuildContext context,
  required Currency currency,
  required DateTime now,
  required Future<void> Function(WealthAsset asset) onSave,
  WealthAsset? initial,
}) async {
  final key = GlobalKey<_AssetFormState>();
  return _showProtectedForm<WealthAsset>(
    context: context,
    title: initial == null ? 'Novo ativo' : 'Atualizar ativo',
    description: 'Cadastre um bem fora das contas. Informe a avaliação conhecida, sem estimativa automática.',
    icon: LucideIcons.landmark,
    saveLabel: initial == null ? 'Salvar ativo' : 'Atualizar ativo',
    failureMessage:
        'Não foi possível salvar o ativo. Revise os dados e tente novamente.',
    content: _AssetForm(
      key: key,
      currency: currency,
      now: now,
      initial: initial,
    ),
    buildValue: () => key.currentState?.buildAsset(),
    setError: (message) => key.currentState?.setSaveError(message),
    onSave: onSave,
  );
}

Future<bool?> showDebtForm({
  required BuildContext context,
  required Currency currency,
  required DateTime now,
  required Future<void> Function(WealthDebt debt) onSave,
  WealthDebt? initial,
}) async {
  final key = GlobalKey<_DebtFormState>();
  return _showProtectedForm<WealthDebt>(
    context: context,
    title: initial == null ? 'Nova dívida' : 'Atualizar dívida',
    description: 'Registre o saldo devedor conhecido. Pagamentos continuam sendo lançados separadamente.',
    icon: LucideIcons.receiptText,
    saveLabel: initial == null ? 'Salvar dívida' : 'Atualizar dívida',
    failureMessage:
        'Não foi possível salvar a dívida. Revise os dados e tente novamente.',
    content: _DebtForm(
      key: key,
      currency: currency,
      now: now,
      initial: initial,
    ),
    buildValue: () => key.currentState?.buildDebt(),
    setError: (message) => key.currentState?.setSaveError(message),
    onSave: onSave,
  );
}

Future<bool?> _showProtectedForm<T>({
  required BuildContext context,
  required String title,
  required String description,
  required IconData icon,
  required String saveLabel,
  required String failureMessage,
  required Widget content,
  required T? Function() buildValue,
  required void Function(String? message) setError,
  required Future<void> Function(T value) onSave,
}) async {
  final saving = ValueNotifier(false);
  Future<void>? activeSave;
  final result = await showPollarAdaptiveModal<bool>(
    context: context,
    title: title,
    description: description,
    icon: icon,
    dismissible: false,
    content: (_) => content,
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
          label: saveLabel,
          loading: isSaving,
          onPressed: isSaving
              ? null
              : () async {
                  final value = buildValue();
                  if (value == null) return;
                  saving.value = true;
                  setError(null);
                  activeSave = () async {
                    try {
                      await onSave(value);
                      if (modalContext.mounted) {
                        Navigator.of(modalContext).pop(true);
                      }
                    } catch (_) {
                      setError(failureMessage);
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

class _GoalForm extends StatefulWidget {
  const _GoalForm({
    super.key,
    required this.currency,
    required this.now,
    this.initial,
  });
  final Currency currency;
  final DateTime now;
  final WealthGoal? initial;

  @override
  State<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<_GoalForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  Money? _target;
  Money? _saved;
  DateTime? _deadline;
  bool _priority = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name);
    _target = initial?.target;
    _saved = initial?.saved;
    _deadline = initial?.deadline;
    _priority = initial?.priority ?? false;
  }

  void setSaveError(String? value) {
    if (mounted) setState(() => _saveError = value);
  }

  WealthGoal? buildGoal() {
    if (!_formKey.currentState!.validate()) return null;
    final initial = widget.initial;
    return WealthGoal(
      id: initial?.id ?? const Uuid().v4(),
      name: _name.text,
      target: _target!,
      saved: _saved ?? Money.zero(widget.currency),
      createdAt: initial?.createdAt ?? widget.now,
      deadline: _deadline,
      priority: _priority,
      active: initial?.active ?? true,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PollarTextField(
          label: 'Nome da meta',
          hint: 'Ex.: Reserva de emergência',
          controller: _name,
          validator: _requiredName,
        ),
        const SizedBox(height: PollarSpacing.x4),
        CurrencyInput(
          label: 'Valor alvo',
          currency: widget.currency,
          initialValue: widget.initial?.target,
          onChanged: (value) => _target = value,
          validator: _positiveMoney,
        ),
        const SizedBox(height: PollarSpacing.x4),
        CurrencyInput(
          label: 'Valor já reservado',
          currency: widget.currency,
          initialValue: widget.initial?.saved ?? Money.zero(widget.currency),
          onChanged: (value) => _saved = value,
          validator: (value) => value == null || !value.isNegative
              ? null
              : 'O valor reservado não pode ser negativo.',
        ),
        const SizedBox(height: PollarSpacing.x4),
        _DateField(
          label: 'Prazo (opcional)',
          value: _deadline,
          onChanged: (value) => setState(() => _deadline = value),
        ),
        PollarCheckbox(
          label: 'Meta prioritária',
          description: 'Aparece no dossiê principal desta moeda.',
          value: _priority,
          onChanged: (value) => setState(() => _priority = value ?? false),
        ),
        _FormError(message: _saveError),
      ],
    ),
  );
}

class _AssetForm extends StatefulWidget {
  const _AssetForm({
    super.key,
    required this.currency,
    required this.now,
    this.initial,
  });
  final Currency currency;
  final DateTime now;
  final WealthAsset? initial;

  @override
  State<_AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<_AssetForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  WealthAssetKind _kind = WealthAssetKind.property;
  Money? _value;
  late DateTime _valuedAt;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name);
    _kind = initial?.kind ?? WealthAssetKind.property;
    _value = initial?.currentValue;
    _valuedAt = initial?.valuedAt ?? widget.now;
  }

  void setSaveError(String? value) {
    if (mounted) setState(() => _saveError = value);
  }

  WealthAsset? buildAsset() {
    if (!_formKey.currentState!.validate()) return null;
    final initial = widget.initial;
    return WealthAsset(
      id: initial?.id ?? const Uuid().v4(),
      name: _name.text,
      kind: _kind,
      currentValue: _value!,
      valuedAt: _valuedAt,
      active: initial?.active ?? true,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PollarTextField(
          label: 'Nome do ativo',
          hint: 'Ex.: Apartamento',
          controller: _name,
          validator: _requiredName,
        ),
        const SizedBox(height: PollarSpacing.x4),
        PollarSelect<WealthAssetKind>(
          label: 'Tipo',
          initialValue: _kind,
          options: [
            for (final kind in WealthAssetKind.values)
              PollarSelectOption(value: kind, label: _assetKindLabel(kind)),
          ],
          onChanged: (value) => setState(() => _kind = value ?? _kind),
        ),
        const SizedBox(height: PollarSpacing.x4),
        CurrencyInput(
          label: 'Valor atual conhecido',
          currency: widget.currency,
          initialValue: widget.initial?.currentValue,
          onChanged: (value) => _value = value,
          validator: _positiveMoney,
        ),
        const SizedBox(height: PollarSpacing.x4),
        _DateField(
          label: 'Data da avaliação',
          value: _valuedAt,
          allowClear: false,
          onChanged: (value) => setState(() => _valuedAt = value!),
        ),
        _FormError(message: _saveError),
      ],
    ),
  );
}

class _DebtForm extends StatefulWidget {
  const _DebtForm({
    super.key,
    required this.currency,
    required this.now,
    this.initial,
  });
  final Currency currency;
  final DateTime now;
  final WealthDebt? initial;

  @override
  State<_DebtForm> createState() => _DebtFormState();
}

class _DebtFormState extends State<_DebtForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _interest;
  WealthDebtKind _kind = WealthDebtKind.financing;
  Money? _original;
  Money? _outstanding;
  DateTime? _dueDate;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name);
    _interest = TextEditingController(
      text: initial == null
          ? '0'
          : NumberFormat(
              '0.##',
              'pt_BR',
            ).format(initial.annualInterestBasisPoints / 100),
    );
    _kind = initial?.kind ?? WealthDebtKind.financing;
    _original = initial?.originalAmount;
    _outstanding = initial?.outstandingAmount;
    _dueDate = initial?.dueDate;
  }

  void setSaveError(String? value) {
    if (mounted) setState(() => _saveError = value);
  }

  WealthDebt? buildDebt() {
    if (!_formKey.currentState!.validate()) return null;
    final interestText = _interest.text.replaceAll(',', '.');
    final interest = double.parse(interestText);
    final initial = widget.initial;
    return WealthDebt(
      id: initial?.id ?? const Uuid().v4(),
      name: _name.text,
      kind: _kind,
      originalAmount: _original!,
      outstandingAmount: _outstanding!,
      annualInterestBasisPoints: (interest * 100).round(),
      dueDate: _dueDate,
      updatedAt: widget.now,
      active: initial?.active ?? true,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _interest.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PollarTextField(
          label: 'Nome da dívida',
          hint: 'Ex.: Financiamento do imóvel',
          controller: _name,
          validator: _requiredName,
        ),
        const SizedBox(height: PollarSpacing.x4),
        PollarSelect<WealthDebtKind>(
          label: 'Tipo',
          initialValue: _kind,
          options: [
            for (final kind in WealthDebtKind.values)
              PollarSelectOption(value: kind, label: _debtKindLabel(kind)),
          ],
          onChanged: (value) => setState(() => _kind = value ?? _kind),
        ),
        const SizedBox(height: PollarSpacing.x4),
        CurrencyInput(
          label: 'Valor original',
          currency: widget.currency,
          initialValue: widget.initial?.originalAmount,
          onChanged: (value) => _original = value,
          validator: _positiveMoney,
        ),
        const SizedBox(height: PollarSpacing.x4),
        CurrencyInput(
          label: 'Saldo devedor atual',
          currency: widget.currency,
          initialValue: widget.initial?.outstandingAmount,
          onChanged: (value) => _outstanding = value,
          validator: (value) => value != null && !value.isNegative
              ? null
              : 'Informe um saldo igual ou maior que zero.',
        ),
        const SizedBox(height: PollarSpacing.x4),
        PollarTextField(
          label: 'Juros anuais (%)',
          controller: _interest,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
          ],
          validator: (value) {
            final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
            return parsed == null || parsed < 0 || parsed > 1000
                ? 'Informe uma taxa entre 0% e 1000%.'
                : null;
          },
        ),
        const SizedBox(height: PollarSpacing.x4),
        _DateField(
          label: 'Vencimento final (opcional)',
          value: _dueDate,
          onChanged: (value) => setState(() => _dueDate = value),
        ),
        _FormError(message: _saveError),
      ],
    ),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.allowClear = true,
  });
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool allowClear;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(PollarRadii.medium),
    onTap: () async {
      final selected = await showDatePicker(
        context: context,
        initialDate: value ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2200),
        helpText: label,
        cancelText: 'Cancelar',
        confirmText: 'Escolher data',
      );
      if (selected != null) onChanged(selected);
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: value != null && allowClear
            ? IconButton(
                tooltip: 'Remover data',
                onPressed: () => onChanged(null),
                icon: const Icon(LucideIcons.x, size: 20),
              )
            : const Icon(LucideIcons.calendarDays, size: 20),
      ),
      child: Text(
        value == null
            ? 'Sem data definida'
            : DateFormat('dd/MM/yyyy', 'pt_BR').format(value!),
      ),
    ),
  );
}

class _FormError extends StatelessWidget {
  const _FormError({required this.message});
  final String? message;

  @override
  Widget build(BuildContext context) => message == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: PollarSpacing.x3),
          child: Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: context.pollar.danger),
          ),
        );
}

String? _requiredName(String? value) => value == null || value.trim().isEmpty
    ? 'Informe um nome para identificar o item.'
    : null;

String? _positiveMoney(Money? value) =>
    value?.isPositive == true ? null : 'Informe um valor maior que zero.';

String _assetKindLabel(WealthAssetKind kind) => switch (kind) {
  WealthAssetKind.property => 'Imóvel',
  WealthAssetKind.vehicle => 'Veículo',
  WealthAssetKind.investment => 'Investimento manual',
  WealthAssetKind.valuable => 'Bem de valor',
  WealthAssetKind.other => 'Outro ativo',
};

String _debtKindLabel(WealthDebtKind kind) => switch (kind) {
  WealthDebtKind.loan => 'Empréstimo',
  WealthDebtKind.financing => 'Financiamento',
  WealthDebtKind.personal => 'Dívida pessoal',
  WealthDebtKind.other => 'Outra dívida',
};

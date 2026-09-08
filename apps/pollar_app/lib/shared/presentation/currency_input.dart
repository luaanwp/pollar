import 'package:flutter/material.dart';

import '../../app/theme/pollar_theme.dart';
import '../../core/money/currency.dart';
import '../../core/money/installment_plan.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/money/money_parser.dart';

/// Decimal pt-BR editing. Invalid/empty text emits null, never a stale amount.
/// Text is kept intact while editing, preserving selection and IME behavior.
class CurrencyInput extends StatefulWidget {
  const CurrencyInput({
    super.key,
    required this.label,
    required this.currency,
    required this.onChanged,
    this.initialValue,
    this.installments = 1,
    this.allowNegative = false,
    this.enabled = true,
    this.readOnly = false,
    this.validator,
  }) : assert(installments >= 1 && installments <= 360);

  final String label;
  final Currency currency;
  final Money? initialValue;
  final ValueChanged<Money?> onChanged;
  final int installments;
  final bool allowNegative;
  final bool enabled;
  final bool readOnly;
  final FormFieldValidator<Money>? validator;

  @override
  State<CurrencyInput> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<CurrencyInput> {
  Money? _amount;
  static const _formatter = MoneyFormatter.ptBr();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null &&
        widget.initialValue!.currency != widget.currency) {
      throw ArgumentError('initialValue must use the input currency');
    }
    _amount = widget.initialValue;
  }

  Money? _parse(String text) {
    try {
      final amount = MoneyParser.parse(text, widget.currency);
      return !widget.allowNegative && amount.isNegative ? null : amount;
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;
    final schedule = amount != null && !amount.isNegative
        ? InstallmentPlan.split(amount, widget.installments)
        : <Money>[];
    final groups = <String>[];
    for (var i = 0; i < schedule.length;) {
      var end = i + 1;
      while (end < schedule.length && schedule[end] == schedule[i]) {
        end++;
      }
      groups.add('${end - i} × ${_formatter.format(schedule[i])}');
      i = end;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          initialValue: widget.initialValue == null
              ? ''
              : _formatter.format(widget.initialValue!),
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          style: PollarTypography.amountStandard.copyWith(
            color: context.pollar.textPrimary,
          ),
          textAlign: TextAlign.right,
          keyboardType: TextInputType.numberWithOptions(
            decimal: true,
            signed: widget.allowNegative,
          ),
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: '${widget.label} (${widget.currency.code})',
            helperText: 'Use vírgula para os centavos, como 100,50.',
          ),
          onChanged: (text) {
            final parsed = _parse(text);
            setState(() => _amount = parsed);
            widget.onChanged(parsed);
          },
          validator: (text) {
            if (text == null || text.trim().isEmpty) return 'Informe o valor.';
            final parsed = _parse(text);
            if (parsed == null) {
              return widget.allowNegative
                  ? 'Informe um valor válido, como −100,50.'
                  : 'Informe um valor positivo, como 100,50.';
            }
            return widget.validator?.call(parsed);
          },
        ),
        if (widget.installments > 1 && schedule.isNotEmpty) ...[
          const SizedBox(height: PollarSpacing.x2),
          Text(
            'Parcelas: ${groups.join(' + ')}. Total: ${_formatter.format(amount!)}.',
            style: PollarTypography.tabular(
              Theme.of(context).textTheme.bodySmall!,
            ).copyWith(color: context.pollar.textSecondary),
          ),
        ],
      ],
    );
  }
}

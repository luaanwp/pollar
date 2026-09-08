import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/pollar_theme.dart';

class PollarSelectOption<T> {
  const PollarSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Single-choice form field with the same geometry and validation as inputs.
class PollarSelect<T> extends StatelessWidget {
  const PollarSelect({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.initialValue,
    this.hint,
    this.enabled = true,
    this.validator,
  });

  final String label;
  final List<PollarSelectOption<T>> options;
  final T? initialValue;
  final String? hint;
  final bool enabled;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: initialValue,
    isExpanded: true,
    icon: const Icon(LucideIcons.chevronDown, size: 20),
    decoration: InputDecoration(labelText: label, helperText: hint),
    items: [
      for (final option in options)
        DropdownMenuItem<T>(value: option.value, child: Text(option.label)),
    ],
    onChanged: enabled ? onChanged : null,
    validator: validator,
  );
}

/// Labeled selection control, including an indeterminate state.
class PollarCheckbox extends StatelessWidget {
  const PollarCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.enabled = true,
    this.tristate = false,
  });

  final String label;
  final String? description;
  final bool? value;
  final bool enabled;
  final bool tristate;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: value,
    tristate: tristate,
    enabled: enabled,
    onChanged: enabled ? onChanged : null,
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    title: Text(label),
    subtitle: description == null ? null : Text(description!),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PollarRadii.medium),
    ),
  );
}

/// Immediate-effect preference toggle with an optional explanation.
class PollarSwitch extends StatelessWidget {
  const PollarSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.enabled = true,
  });

  final String label;
  final String? description;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    value: value,
    onChanged: enabled ? onChanged : null,
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: description == null ? null : Text(description!),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PollarRadii.medium),
    ),
  );
}

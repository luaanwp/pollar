import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/pollar_theme.dart';

/// Text entry using the app theme and native Form validation/focus behavior.
class PollarTextField extends StatelessWidget {
  const PollarTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.leadingIcon,
    this.trailingIcon,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool readOnly;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final externalLabel = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (externalLabel) ...[
          ExcludeSemantics(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: context.pollar.textSecondary),
            ),
          ),
          const SizedBox(height: PollarSpacing.x2),
        ],
        Semantics(
          key: const ValueKey('pollar-text-entry'),
          label: externalLabel ? label : null,
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            readOnly: readOnly,
            validator: validator,
            onChanged: onChanged,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            maxLines: maxLines,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: externalLabel ? null : label,
              hintText: hint,
              prefixIcon: leadingIcon == null
                  ? null
                  : Icon(leadingIcon, size: 20),
              suffixIcon: trailingIcon == null
                  ? null
                  : Icon(trailingIcon, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

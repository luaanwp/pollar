import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  Widget build(BuildContext context) => TextFormField(
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
      labelText: label,
      hintText: hint,
      prefixIcon: leadingIcon == null ? null : Icon(leadingIcon, size: 20),
      suffixIcon: trailingIcon == null ? null : Icon(trailingIcon, size: 20),
    ),
  );
}

import 'package:flutter/material.dart';

import 'field_chrome.dart';

/// A text field laid out like the pickers and dropdowns: [label] above,
/// [icon] inside, [hintText] until something is typed.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: icon == null ? null : FieldIcon(icon),
          prefixIconConstraints: fieldPrefixConstraints,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/theme_context.dart';
import 'field_chrome.dart';

/// A text field laid out like the pickers and dropdowns: [label] above,
/// [icon] inside, [hintText] until something is typed. An [obscureText] field
/// ends in an eye that shows what was typed.
class AppTextField extends StatefulWidget {
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
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final icon = widget.icon;
    return LabeledField(
      label: widget.label,
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        obscureText: _hidden,
        errorBuilder: (_, message) => FieldError(message),
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: icon == null ? null : FieldIcon(icon),
          prefixIconConstraints: fieldPrefixConstraints,
          suffixIcon: widget.obscureText ? _eye(context) : null,
        ),
      ),
    );
  }

  Widget _eye(BuildContext context) => IconButton(
        tooltip: _hidden ? 'Show password' : 'Hide password',
        color: context.palette.secondaryText,
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          size: AppLayout.fieldIconSize.r,
        ),
      );
}

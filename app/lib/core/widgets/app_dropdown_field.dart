import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.value,
    this.itemLabel,
    this.validator,
    this.prefixIcon,
  });

  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String hintText;
  final T? value;
  final String Function(T item)? itemLabel;
  final FormFieldValidator<T>? validator;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: items.contains(value) ? value : null,
      key: ValueKey(value),
      isExpanded: true,
      dropdownColor: context.palette.card,
      style: context.textStyles.bodyMedium,
      hint: Text(hintText, style: context.theme.inputDecorationTheme.hintStyle),
      decoration: InputDecoration(
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
      validator: validator,
      onChanged: onChanged,
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel?.call(item) ?? item.toString()),
          ),
      ],
    );
  }
}

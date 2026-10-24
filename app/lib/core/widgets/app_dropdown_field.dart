import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/theme_context.dart';
import 'field_chrome.dart';

/// A dropdown laid out like the other fields: [label] above, [prefixIcon]
/// inside, [hintText] until a [value] is chosen.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.label,
    this.value,
    this.itemLabel,
    this.validator,
    this.prefixIcon,
  });

  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String hintText;
  final String? label;
  final T? value;
  final String Function(T item)? itemLabel;
  final FormFieldValidator<T>? validator;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final prefixIcon = this.prefixIcon;
    final palette = context.palette;
    return LabeledField(
      label: label,
      child: DropdownButtonFormField<T>(
        initialValue: items.contains(value) ? value : null,
        key: ValueKey(value),
        isExpanded: true,
        dropdownColor: palette.cardElevated,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        icon: const Icon(Icons.expand_more_rounded),
        iconEnabledColor: palette.secondaryText,
        style: context.textStyles.bodyMedium,
        hint: Text(
          hintText,
          style: context.theme.inputDecorationTheme.hintStyle,
        ),
        decoration: InputDecoration(
          prefixIcon: prefixIcon == null ? null : FieldIcon(prefixIcon),
          prefixIconConstraints: fieldPrefixConstraints,
        ),
        validator: validator,
        errorBuilder: (_, message) => FieldError(message),
        onChanged: onChanged,
        items: [
          for (final item in items)
            DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel?.call(item) ?? item.toString()),
            ),
        ],
      ),
    );
  }
}

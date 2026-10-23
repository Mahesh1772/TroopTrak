import 'package:flutter/material.dart';

import '../theme/app_layout.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme_builder.dart';
import '../theme/theme_context.dart';
import 'field_chrome.dart';

const _verticalPadding =
    (AppLayout.searchHeight - AppLayout.fieldLineHeight) / 2;

/// A 46 px pill with a leading magnifier, styled by the shared input theme.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.onChanged,
    this.controller,
    this.hintText = 'Search...',
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: buildInputDecorationTheme(
          context.palette,
          radius: AppLayout.searchHeight / 2,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.control,
            vertical: _verticalPadding,
          ),
          prefixIcon: const FieldIcon(
            Icons.search_rounded,
            size: AppLayout.searchIconSize,
          ),
          prefixIconConstraints: fieldPrefixConstraints,
        ),
      ),
    );
  }
}

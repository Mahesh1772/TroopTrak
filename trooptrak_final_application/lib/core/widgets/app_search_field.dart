import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/theme_context.dart';

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
    final style =
        context.textStyles.bodyMedium?.copyWith(color: AppColors.white);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: style,
      cursorColor: AppColors.white,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: style,
        prefixIcon: const Icon(Icons.search_sharp, color: AppColors.white),
        fillColor: AppColors.brandIndigo,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

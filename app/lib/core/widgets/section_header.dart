import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.trailing,
    this.padding,
    this.icon,
  });

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.xl.w,
            vertical: AppSpacing.sm.h,
          ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 30.sp, color: context.colors.onSurface),
            SizedBox(width: AppSpacing.xl.w),
          ],
          Expanded(
            child: Text(
              title,
              style: context.textStyles.displayMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

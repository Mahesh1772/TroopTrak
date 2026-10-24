import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';

/// The top of an auth page: an optional [leading] mark, the [title] and a
/// [subtitle] under it.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
  });

  final String title;
  final String subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading,
          SizedBox(height: AppSpacing.xxl.h),
        ],
        Text(title, style: AppTextStyles.screenTitle(context.colors.onSurface)),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          subtitle,
          style: AppTextStyles.screenSubtitle(context.palette.secondaryText),
        ),
      ],
    );
  }
}

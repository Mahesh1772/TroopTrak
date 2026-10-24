import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';

/// A line of secondary text ending in an accent link, such as
/// "Did not receive OTP? Resend New OTP". [actionKey] goes on the link.
class LinkPrompt extends StatelessWidget {
  const LinkPrompt({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
    this.actionKey,
    this.alignment = WrapAlignment.start,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;
  final Key? actionKey;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Wrap(
      alignment: alignment,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs.w,
      children: [
        Text(
          prompt,
          style: AppTextStyles.subtitle(palette.secondaryText),
        ),
        InkWell(
          key: actionKey,
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.xs),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
            child: Text(
              action,
              style: AppTextStyles.link(palette.accentText),
            ),
          ),
        ),
      ],
    );
  }
}

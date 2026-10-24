import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';

/// A tappable [label] in the accent text colour.
class LinkButton extends StatelessWidget {
  const LinkButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.xs),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
          child: Text(
            label,
            style: AppTextStyles.link(context.palette.accentText),
          ),
        ),
      );
}

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
  Widget build(BuildContext context) => Wrap(
        alignment: alignment,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs.w,
        children: [
          Text(
            prompt,
            style: AppTextStyles.subtitle(context.palette.secondaryText),
          ),
          LinkButton(key: actionKey, label: action, onTap: onTap),
        ],
      );
}

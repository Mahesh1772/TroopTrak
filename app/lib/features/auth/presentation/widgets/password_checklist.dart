import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../domain/validators/password_rules.dart';

/// One row per [PasswordRule], green once the typed password passes it and red
/// until then.
class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs.h,
          children: [
            for (final rule in PasswordRule.values)
              Row(
                spacing: AppSpacing.sm.w,
                children: [
                  Icon(
                    rule.passes(value.text)
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: AppLayout.checklistIcon.r,
                    color: rule.passes(value.text)
                        ? palette.successText
                        : palette.leaveText,
                  ),
                  Text(
                    rule.label,
                    style: AppTextStyles.subtitle(palette.secondaryText),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

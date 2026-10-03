import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.military_tech_outlined,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Column(
      children: [
        Icon(icon, size: 150.sp, color: AppColors.authIcon),
        SizedBox(height: AppSpacing.xxl.h),
        Text(title,
            textAlign: TextAlign.center,
            style: text.displayLarge
                ?.copyWith(fontSize: 35.sp, color: AppColors.authLink)),
        SizedBox(height: AppSpacing.sm.h),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: text.displaySmall?.copyWith(color: AppColors.authSubtitle)),
      ],
    );
  }
}

class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
    this.actionKey,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    final style = context.textStyles.titleSmall;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: style?.copyWith(color: AppColors.white)),
        const SizedBox(width: 6),
        GestureDetector(
          key: actionKey,
          onTap: onTap,
          child: Text(action,
              style: style?.copyWith(
                  color: AppColors.authAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';

class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.pressed,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final bool pressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(30.r);
    final offset = pressed ? 5.0 : 10.0;
    final blur = pressed ? 5.0 : 20.0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: 170.w,
        height: 280.h,
        decoration: BoxDecoration(
          color: AppColors.roleCard,
          borderRadius: radius,
          gradient: pressed
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.roleShadowDark, AppColors.roleCard],
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.roleShadowLight,
              offset: Offset(-offset.w, -offset.h),
              blurRadius: blur.r,
            ),
            BoxShadow(
              color: AppColors.roleShadowDark,
              offset: Offset(offset.w, offset.h),
              blurRadius: blur.r,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: 50.w, color: AppColors.white),
            SizedBox(height: AppSpacing.xl.h),
            Text(title,
                style: context.textStyles.titleLarge
                    ?.copyWith(color: AppColors.white)),
            Text(subtitle,
                style: context.textStyles.bodyMedium
                    ?.copyWith(color: AppColors.white60)),
          ],
        ),
      ),
    );
  }
}

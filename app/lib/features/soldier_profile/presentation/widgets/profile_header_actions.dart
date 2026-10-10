import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/theme/theme_manager.dart';

/// Translucent pill used for SIGN OUT (and SHOW QR CODE on the soldier side).
class HeaderPillButton extends StatelessWidget {
  const HeaderPillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.xl.r);
    return Material(
      color: AppColors.black.withValues(alpha: 0.1),
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          width: 300.w,
          padding: EdgeInsets.all(AppSpacing.lg.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.white, size: 35.sp),
              SizedBox(width: AppSpacing.xl.w),
              Text(label,
                  style: context.textStyles.displaySmall
                      ?.copyWith(color: AppColors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Source rolling light/dark switch; true is dark.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<ThemeManager>();
    return AnimatedToggleSwitch<bool>.rolling(
      key: const Key('themeToggle'),
      current: manager.isDark,
      values: const [false, true],
      onChanged: manager.setDark,
      height: 40.h,
      spacing: 10.w,
      borderWidth: 3.w,
      iconBuilder: (dark, _) => dark
          ? const Icon(Icons.dark_mode_rounded, color: AppColors.white)
          : const Icon(Icons.light_mode_rounded,
              color: AppColors.lightModeIcon),
      style: ToggleStyle(
        indicatorColor: context.colors.surface,
        backgroundColor: AppColors.warning,
        borderColor: Colors.transparent,
      ),
    );
  }
}

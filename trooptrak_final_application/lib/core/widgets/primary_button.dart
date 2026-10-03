import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

enum PrimaryButtonStyle { form, brand, danger }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.style = PrimaryButtonStyle.form,
    this.expand = true,
    this.pill = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final PrimaryButtonStyle style;
  final bool expand;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = switch (style) {
      PrimaryButtonStyle.form => palette.buttonGradient,
      PrimaryButtonStyle.brand => palette.headerGradient,
      PrimaryButtonStyle.danger => const [
          AppColors.danger,
          AppColors.dangerGradientEnd
        ],
    };
    final enabled = onPressed != null && !loading;
    final radius =
        BorderRadius.circular((pill ? AppRadii.pill : AppRadii.lg).r);
    final labelStyle =
        context.textStyles.titleLarge?.copyWith(color: AppColors.white);

    return Opacity(
      opacity: enabled || loading ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg.w,
                vertical: AppSpacing.md.h,
              ),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    SizedBox.square(
                      dimension: 20.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  else ...[
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.white),
                      SizedBox(width: AppSpacing.sm.w),
                    ],
                    Flexible(child: Text(label, style: labelStyle)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

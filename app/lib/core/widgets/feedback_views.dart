import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// A centred note for a list with nothing in it: an optional muted [icon], a
/// bold [message] and a [subtitle] beneath.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.subtitle,
  });

  final String message;
  final IconData? icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final icon = this.icon;
    final subtitle = this.subtitle;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl.w,
          vertical: AppLayout.emptyVertical.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xs.h,
          children: [
            if (icon != null)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
                child: Icon(
                  icon,
                  size: AppLayout.emptyIconSize.r,
                  color: palette.mutedText,
                ),
              ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.barlow(17, FontWeight.w700, palette.onCard),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.barlow(
                    16, FontWeight.w400, palette.secondaryText),
              ),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/assets/icons8-error-64.png',
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.error_outline, color: context.palette.danger),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(message, textAlign: TextAlign.center, style: text.bodyMedium),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.md.h),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

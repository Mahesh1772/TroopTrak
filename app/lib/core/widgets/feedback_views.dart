import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.image = 'lib/assets/noConductspng.png',
    this.subtitle,
  });

  final String message;
  final String? image;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null)
              Image.asset(image!,
                  errorBuilder: (_, __, ___) => const SizedBox()),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    text.displayLarge?.copyWith(fontWeight: FontWeight.w500)),
            if (subtitle != null)
              Text(subtitle!,
                  textAlign: TextAlign.center, style: text.bodySmall),
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

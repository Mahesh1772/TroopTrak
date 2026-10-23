import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

/// The strip holding a page's primary action. Put it last in a `Column` under
/// an `Expanded` scroll view: the Scaffold shrinks its body above the
/// keyboard, so the bar rides with it, and it clears the home indicator.
class StickyCtaBar extends StatelessWidget {
  const StickyCtaBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: context.colors.surface,
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.only(bottom: AppSpacing.md.h),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg.w,
              AppSpacing.md.h,
              AppSpacing.lg.w,
              AppSpacing.md.h,
            ),
            child: child,
          ),
        ),
      );
}

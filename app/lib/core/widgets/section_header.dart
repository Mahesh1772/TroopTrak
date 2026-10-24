import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';

/// A small heading with an optional [caption] on its right, such as a count.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.caption,
    this.padding,
  });

  final String title;
  final String? caption;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final caption = this.caption;
    return Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(
            AppSpacing.xl.w,
            AppLayout.sectionTop.h,
            AppSpacing.xl.w,
            AppLayout.sectionBottom.h,
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: AppSpacing.sm.w,
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: AppTextStyles.h3(palette.onCard)),
            ),
          ),
          if (caption != null)
            Text(
              caption,
              maxLines: 1,
              style: AppTextStyles.caption(palette.secondaryText).copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

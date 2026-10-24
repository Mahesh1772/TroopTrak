import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';
import 'sticky_cta_page.dart';

/// A form page: an optional [title] bar, a [subtitle], the scrolling
/// [children], and the [cta] pinned under them. Without a [title] the page has
/// no app bar.
class FormPageScaffold extends StatelessWidget {
  const FormPageScaffold({
    super.key,
    required this.formKey,
    required this.children,
    required this.cta,
    this.title,
    this.subtitle,
  });

  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final Widget cta;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final subtitle = this.subtitle;
    return StickyCtaPage(
      formKey: formKey,
      horizontal: AppSpacing.lg,
      top: 0,
      spacing: AppSpacing.md,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      appBar: title == null
          ? null
          : AppBar(
              toolbarHeight: AppLayout.appBarHeight.h,
              backgroundColor: context.colors.surface,
              scrolledUnderElevation: 0,
              title: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.compactTitle(context.colors.onSurface),
              ),
            ),
      cta: cta,
      children: [
        if (subtitle != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
            child: Text(
              subtitle,
              style: AppTextStyles.subtitle(context.palette.secondaryText),
            ),
          ),
        ...children,
      ],
    );
  }
}

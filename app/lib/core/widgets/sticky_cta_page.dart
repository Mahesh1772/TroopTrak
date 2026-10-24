import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_spacing.dart';
import 'sticky_cta_bar.dart';

/// A page whose [children] scroll with [cta] pinned under them, above the
/// keyboard. [horizontal] insets both, [top] is the space above the first
/// child and [spacing] the gap between children, all in design px. A
/// [formKey] wraps the children in a validating `Form`.
class StickyCtaPage extends StatelessWidget {
  const StickyCtaPage({
    super.key,
    required this.children,
    required this.cta,
    this.appBar,
    this.formKey,
    this.horizontal = AppSpacing.xxl,
    this.top = AppSpacing.xl,
    this.spacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final Widget cta;
  final PreferredSizeWidget? appBar;
  final GlobalKey<FormState>? formKey;
  final double horizontal;
  final double top;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final formKey = this.formKey;
    final Widget scroll = SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        horizontal.w,
        top.h,
        horizontal.w,
        AppSpacing.lg.h,
      ),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        spacing: spacing.h,
        children: children,
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: formKey == null
                  ? scroll
                  : Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: scroll,
                    ),
            ),
            StickyCtaBar(horizontal: horizontal, child: cta),
          ],
        ),
      ),
    );
  }
}

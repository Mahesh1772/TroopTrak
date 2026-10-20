import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/theme_context.dart';

const _statusBar = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

/// Brand gradient that runs to the top edge, behind the status bar. The
/// [child] starts below the status bar and sets its own side padding.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.child,
    this.bottom = AppLayout.headerBottom,
  });

  final Widget child;

  /// Space under [child], in design px.
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _statusBar,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: context.palette.headerGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom.h),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

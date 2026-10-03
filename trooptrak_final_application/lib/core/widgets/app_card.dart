import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.gradient,
    this.padding,
    this.margin,
    this.radius = AppRadii.lg,
    this.shadows = AppShadows.card,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius.r);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? context.palette.card) : null,
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: padding ?? EdgeInsets.all(AppSpacing.md.r),
            child: child,
          ),
        ),
      ),
    );
  }
}

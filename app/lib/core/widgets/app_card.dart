import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/theme_context.dart';

/// A plain rounded card, on the palette's card colour unless [color] is given.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius = AppRadii.xl,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) => Material(
        color: color ?? context.palette.card,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      );
}

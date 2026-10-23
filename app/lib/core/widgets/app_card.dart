import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/theme_context.dart';

/// A plain rounded card on the palette's card colour.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Material(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      );
}

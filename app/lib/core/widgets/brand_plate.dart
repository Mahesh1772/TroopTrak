import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/app_radii.dart';
import '../theme/theme_context.dart';

/// A 64 px rounded plate on the brand gradient holding a white [icon], the
/// mark above a sign-in heading.
class BrandPlate extends StatelessWidget {
  const BrandPlate(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: AppLayout.brandPlate.r,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: context.palette.headerGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadii.tile.r),
          ),
          child: Icon(
            icon,
            size: AppLayout.brandPlateIcon.r,
            color: AppColors.white,
          ),
        ),
      );
}

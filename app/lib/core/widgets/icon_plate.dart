import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_radii.dart';
import '../theme/theme_context.dart';
import 'state_tone.dart';

/// A small rounded plate holding an [icon] in the tint and text colour of
/// [tone], the leading element of a list row.
class IconPlate extends StatelessWidget {
  const IconPlate(this.icon, {super.key, required this.tone});

  final IconData icon;
  final StateTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox.square(
      dimension: AppLayout.iconPlateSize.r,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tone.tint(palette),
          borderRadius: BorderRadius.circular(AppRadii.sm.r),
        ),
        child: Icon(
          icon,
          size: AppLayout.iconPlateIcon.r,
          color: tone.text(palette),
        ),
      ),
    );
  }
}

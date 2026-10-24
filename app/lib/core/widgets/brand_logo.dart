import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/theme_context.dart';

const _asset = 'lib/assets/phone_auth/troopTrak_logo.png';

const _invertColours = ColorFilter.matrix([
  -1, 0, 0, 0, 255, //
  0, -1, 0, 0, 255,
  0, 0, -1, 0, 255,
  0, 0, 0, 1, 0,
]);

/// The TroopTrak wordmark. The artwork is black on a transparent square, so it
/// is inverted to white on the dark theme. [width] is in design px.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      _asset,
      width: width.w,
      semanticLabel: 'TroopTrak',
    );
    return context.isDark
        ? ColorFiltered(colorFilter: _invertColours, child: logo)
        : logo;
  }
}

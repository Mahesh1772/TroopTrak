import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/theme_context.dart';

const _asset = 'lib/assets/phone_auth/troopTrak_mascot.png';

/// The TroopTrak mascot, tinted with the accent text colour. [height] is in
/// design px.
class BrandMascot extends StatelessWidget {
  const BrandMascot({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Image.asset(
        _asset,
        height: height.h,
        color: context.palette.accentText,
        excludeFromSemantics: true,
      );
}

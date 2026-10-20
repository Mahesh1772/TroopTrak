import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static const tile = [
    BoxShadow(
      blurRadius: 2,
      spreadRadius: 2,
      offset: Offset(10, 10),
      color: AppColors.black54,
    ),
  ];

  static const segment = [
    BoxShadow(
      blurRadius: 6,
      spreadRadius: -2,
      offset: Offset(0, 2),
      color: AppColors.segmentShadow,
    ),
  ];
}

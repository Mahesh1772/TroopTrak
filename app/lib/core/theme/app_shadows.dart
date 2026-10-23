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

  static List<BoxShadow> button(Color color) => [
        BoxShadow(
          blurRadius: 18,
          spreadRadius: -10,
          offset: const Offset(0, 8),
          color: color.withValues(alpha: 0.9),
        ),
      ];

  static List<BoxShadow> raised({required bool dark}) => [
        BoxShadow(
          blurRadius: dark ? 32 : 28,
          spreadRadius: dark ? -12 : -14,
          offset: const Offset(0, 12),
          color:
              dark ? AppColors.raisedShadowDark : AppColors.raisedShadowLight,
        ),
      ];
}

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

  static const card = [
    BoxShadow(
      blurRadius: 8,
      spreadRadius: 1,
      offset: Offset(0, 4),
      color: Color(0x33000000),
    ),
  ];
}

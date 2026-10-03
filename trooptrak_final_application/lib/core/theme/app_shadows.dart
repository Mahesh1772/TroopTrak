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
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum SnackKind { success, error, info }

abstract final class AppSnackbar {
  static void success(BuildContext context, String message) =>
      show(context, message, SnackKind.success);

  static void error(BuildContext context, String message) =>
      show(context, message, SnackKind.error);

  static void info(BuildContext context, String message) =>
      show(context, message, SnackKind.info);

  static void show(BuildContext context, String message, SnackKind kind) {
    final (icon, color) = switch (kind) {
      SnackKind.success => (Icons.check_circle_rounded, AppColors.success),
      SnackKind.error => (Icons.error_rounded, AppColors.danger),
      SnackKind.info => (Icons.info_rounded, AppColors.accent),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}

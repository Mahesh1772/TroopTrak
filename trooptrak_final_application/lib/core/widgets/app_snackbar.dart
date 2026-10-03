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

  /// A write's result: [error] when it failed, otherwise [success].
  static void outcome(BuildContext context, String? error,
          {required String success}) =>
      error == null
          ? AppSnackbar.success(context, success)
          : AppSnackbar.error(context, error);

  static void show(BuildContext context, String message, SnackKind kind) =>
      showOn(ScaffoldMessenger.of(context), message, kind);

  /// For results that arrive after the calling widget may have gone.
  static void showOn(
      ScaffoldMessengerState messenger, String message, SnackKind kind) {
    final (icon, color) = switch (kind) {
      SnackKind.success => (Icons.check_circle_rounded, AppColors.success),
      SnackKind.error => (Icons.error_rounded, AppColors.danger),
      SnackKind.info => (Icons.info_rounded, AppColors.accent),
    };
    messenger
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

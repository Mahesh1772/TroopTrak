import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';

const _iconSize = 18.0;
const _fontSize = 13.5;

/// An error line with a leading icon, for a message that belongs to a group of
/// fields rather than to one text field.
class InlineError extends StatelessWidget {
  const InlineError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = context.palette.leaveText;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
      child: Row(
        spacing: AppSpacing.xs.w,
        children: [
          Icon(Icons.error_rounded, size: _iconSize.r, color: color),
          Flexible(
            child: Text(
              message,
              style: AppTextStyles.barlow(_fontSize, FontWeight.w400, color),
            ),
          ),
        ],
      ),
    );
  }
}

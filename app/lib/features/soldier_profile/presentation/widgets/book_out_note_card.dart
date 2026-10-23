import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/state_tone.dart';

const _iconSize = 20.0;
const _fontSize = 14.5;

/// A tinted note with an info icon: the book-out rule of a Leave or MA.
class BookOutNoteCard extends StatelessWidget {
  const BookOutNoteCard(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const tone = StateTone.medical;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.tint(palette),
        borderRadius: BorderRadius.circular(AppRadii.lg.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.control.w,
          vertical: AppSpacing.md.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.tight.w,
          children: [
            Icon(
              Icons.info_rounded,
              size: _iconSize.r,
              color: tone.text(palette),
            ),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.barlow(
                  _fontSize,
                  FontWeight.w400,
                  context.colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

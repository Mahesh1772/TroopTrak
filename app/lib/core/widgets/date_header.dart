import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';
import '../utils/date_formats.dart';

const _pickerIconSize = 24.0;
const _labelLineHeight = 1.05;

/// The long date over "Today" (or the weekday on any other day), with a
/// calendar button to pick a date and an optional [action] on the right.
class DateHeader extends StatelessWidget {
  const DateHeader({
    super.key,
    required this.date,
    required this.today,
    required this.onPickDate,
    this.pickerKey,
    this.action,
  });

  final DateTime date;
  final DateTime today;
  final VoidCallback onPickDate;
  final Key? pickerKey;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final action = this.action;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        AppSpacing.xs.h,
        AppSpacing.lg.w,
        AppSpacing.lg.h,
      ),
      child: Row(
        spacing: AppSpacing.md.w,
        children: [
          IconButton(
            key: pickerKey,
            tooltip: 'Pick a date',
            onPressed: onPickDate,
            iconSize: _pickerIconSize.r,
            icon: const Icon(Icons.calendar_month_rounded),
            style: IconButton.styleFrom(
              fixedSize: Size.square(AppLayout.dateButtonSize.r),
              backgroundColor: palette.cardElevated,
              foregroundColor: palette.onCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.control.r),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatLongDate(date),
                  style: text.bodySmall?.copyWith(color: palette.secondaryText),
                ),
                Text(
                  isSameDay(date, today) ? 'Today' : formatWeekday(date),
                  style: text.displayLarge?.copyWith(height: _labelLineHeight),
                ),
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
}

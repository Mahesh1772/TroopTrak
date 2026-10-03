import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/calendar_event.dart';
import '../providers/dashboard_providers.dart';

/// Month grid replacing the source's Syncfusion calendar (D8): dots mark
/// conducts (amber) and guard duties (pink); the picked day is listed below.
class EventCalendar extends StatelessWidget {
  const EventCalendar({super.key});

  static final _monthTitle = DateFormat('MMMM yyyy', 'en_US');
  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static Color colorOf(CalendarEventKind kind) => switch (kind) {
        CalendarEventKind.conduct => AppColors.warning,
        CalendarEventKind.guardDuty => AppColors.calendarDuty,
      };

  @override
  Widget build(BuildContext context) {
    final calendar = context.watch<EventCalendarProvider>();
    final text = context.textStyles;
    final month = calendar.month;
    final leading = month.weekday - 1;
    final days = DateTime(month.year, month.month + 1, 0).day;
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('prevMonth'),
              onPressed: () => calendar.shiftMonth(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(_monthTitle.format(month),
                  textAlign: TextAlign.center, style: text.headlineLarge),
            ),
            IconButton(
              key: const Key('nextMonth'),
              onPressed: () => calendar.shiftMonth(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Row(
          children: [
            for (final d in _weekdays)
              Expanded(
                child: Text(d,
                    textAlign: TextAlign.center, style: text.labelMedium),
              ),
          ],
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < leading; i++) const SizedBox.shrink(),
            for (var d = 1; d <= days; d++)
              _DayCell(day: DateTime(month.year, month.month, d)),
          ],
        ),
        const Divider(),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(formatLongDate(calendar.selected),
              style: text.headlineLarge),
        ),
        for (final e in calendar.on(calendar.selected))
          ListTile(
            key: Key('event-${e.title}-${e.start.toIso8601String()}'),
            leading: Icon(Icons.circle, color: colorOf(e.kind), size: 14.sp),
            title: Text(e.title, style: text.titleMedium),
            subtitle: Text('${formatTime(e.start)} - ${formatTime(e.end)}',
                style: text.bodySmall),
          ),
        if (calendar.on(calendar.selected).isEmpty)
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg.sp),
            child: Text('No events', style: text.bodySmall),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final calendar = context.watch<EventCalendarProvider>();
    final selected = isSameDay(day, calendar.selected);
    final kinds = calendar.kindsOn(day);
    return InkWell(
      key: Key('day-${formatDay(day)}'),
      borderRadius: BorderRadius.circular(AppRadii.md.r),
      onTap: () => calendar.select(day),
      child: Container(
        margin: EdgeInsets.all(AppSpacing.xxs.sp),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandIndigo : null,
          borderRadius: BorderRadius.circular(AppRadii.md.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.day}',
                style: context.textStyles.titleSmall
                    ?.copyWith(color: selected ? AppColors.white : null)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final k in kinds)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs.w),
                    child: Icon(Icons.circle,
                        size: 6.sp, color: EventCalendar.colorOf(k)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

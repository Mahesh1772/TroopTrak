import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_view.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/services/month_grid.dart';
import '../providers/dashboard_providers.dart';

const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const _dayFont = 17.0;
const _weekdayFont = 12.5;
const _timeFont = 15.0;
const _rangeFont = 14.0;
const _dotGap = 3.0;

Color _colorOf(AppPalette palette, CalendarEventKind kind) => switch (kind) {
      CalendarEventKind.conduct => palette.warning,
      CalendarEventKind.guardDuty => palette.duty,
    };

/// Month card with dots for conducts and guard duties, then the picked day's
/// events in a list card below.
class EventCalendar extends StatelessWidget {
  const EventCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final calendar = context.watch<EventCalendarProvider>();
    final events = calendar.selectedEvents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MonthCard(calendar: calendar),
        SectionHeader(
          formatLongDate(calendar.selected),
          caption: events.isEmpty
              ? null
              : '${events.length} ${events.length == 1 ? 'event' : 'events'}',
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xs.w,
            AppLayout.calendarSectionTop.h,
            AppSpacing.xs.w,
            AppSpacing.sm.h,
          ),
        ),
        StateView<List<CalendarEvent>>(
          state: calendar.state,
          isEmpty: (_) => events.isEmpty,
          empty: const EmptyState(
            message: 'No events',
            icon: Icons.event_busy_rounded,
          ),
          builder: (context, _) => AppListCard(
            dividerInset: 0,
            children: [for (final e in events) _EventRow(event: e)],
          ),
        ),
      ],
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.calendar});

  final EventCalendarProvider calendar;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(AppRadii.xl.r),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md.w,
          AppSpacing.md.h,
          AppSpacing.md.w,
          AppSpacing.control.h,
        ),
        child: Column(
          children: [
            _MonthNav(calendar: calendar),
            const _WeekdayRow(),
            Column(
              spacing: AppLayout.calendarRowGap.h,
              children: [
                for (final week in calendar.weeks)
                  Row(
                    children: [
                      for (final cell in week)
                        Expanded(
                          child: _DayCell(
                            cell: cell,
                            selected: isSameDay(cell.date, calendar.selected),
                            today: isSameDay(cell.date, calendar.today),
                            kinds: calendar.kindsOn(cell.date),
                            onTap: () => calendar.select(cell.date),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({required this.calendar});

  final EventCalendarProvider calendar;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    Widget button(Key key, IconData icon, String tooltip, int delta) =>
        IconButton(
          key: key,
          tooltip: tooltip,
          onPressed: () => calendar.shiftMonth(delta),
          icon: Icon(icon),
          color: palette.onCard,
          style: IconButton.styleFrom(
            fixedSize: Size.square(AppLayout.calendarNavButton.r),
          ),
        );
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.tight.h),
      child: Row(
        children: [
          button(const Key('prevMonth'), Icons.chevron_left_rounded,
              'Previous month', -1),
          Expanded(
            child: Text(
              formatMonthYear(calendar.month),
              textAlign: TextAlign.center,
              style: AppTextStyles.h2(palette.onCard),
            ),
          ),
          button(const Key('nextMonth'), Icons.chevron_right_rounded,
              'Next month', 1),
        ],
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.barlow(
        _weekdayFont, FontWeight.w600, context.palette.secondaryText);
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.inline.h),
      child: Row(
        children: [
          for (final d in _weekdays)
            Expanded(
              child: Text(d, textAlign: TextAlign.center, style: style),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.cell,
    required this.selected,
    required this.today,
    required this.kinds,
    required this.onTap,
  });

  final MonthCell cell;
  final bool selected;
  final bool today;
  final List<CalendarEventKind> kinds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final date = cell.date;
    if (!cell.inMonth) {
      return SizedBox(
        height: AppLayout.calendarDayHeight.h,
        child: Opacity(
          opacity: AppLayout.calendarMutedOpacity,
          child: Center(
            child: Text(
              '${date.day}',
              style: AppTextStyles.figure(
                  _dayFont, FontWeight.w500, palette.mutedText),
            ),
          ),
        ),
      );
    }
    final ring = today && !selected;
    return SizedBox(
      height: AppLayout.calendarDayHeight.h,
      child: Material(
        color: selected ? AppColors.brandIndigo : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg.r),
          side: ring
              ? BorderSide(
                  color: palette.accentText,
                  width: AppLayout.calendarTodayRing.r,
                )
              : BorderSide.none,
        ),
        child: InkWell(
          key: Key('day-${formatDay(date)}'),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg.r),
          ),
          hoverColor: palette.hover,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppSpacing.xs.h,
            children: [
              Text(
                '${date.day}',
                style: AppTextStyles.figure(
                  _dayFont,
                  FontWeight.w500,
                  selected ? AppColors.white : palette.onCard,
                ),
              ),
              SizedBox(
                height: AppLayout.calendarDot.r,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: _dotGap.w,
                  children: [
                    for (final kind in kinds)
                      _Dot(
                        key: Key('dot-${formatDay(date)}-${kind.name}'),
                        color: _colorOf(palette, kind),
                        size: AppLayout.calendarDot,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({super.key, required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: SizedBox.square(dimension: size.r),
      );
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.md.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSpacing.control.w,
        children: [
          for (final kind in CalendarEventKind.values)
            Row(
              key: Key('legend-${kind.name}'),
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.inline.w,
              children: [
                _Dot(
                  color: _colorOf(palette, kind),
                  size: AppLayout.calendarLegendDot,
                ),
                Text(
                  kind.label,
                  style: AppTextStyles.caption(palette.secondaryText),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final range = '${formatTime(event.start)} - ${formatTime(event.end)}'
        '${event.endsNextDay ? ' (Next day)' : ''}';
    return AppListRow(
      key: Key('event-${event.title}-${event.start.toIso8601String()}'),
      title: event.title,
      subtitle: Text(
        range,
        style: AppTextStyles.figure(
            _rangeFont, FontWeight.w500, palette.secondaryText),
      ),
      leading: Row(
        spacing: AppSpacing.md.w,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: _colorOf(palette, event.kind),
              borderRadius: BorderRadius.circular(AppRadii.xs.r),
            ),
            child: SizedBox(
              width: AppLayout.calendarEventBar.width.w,
              height: AppLayout.calendarEventBar.height.h,
            ),
          ),
          SizedBox(
            width: AppLayout.calendarEventTime.w,
            child: Text(
              formatTime(event.start),
              style: AppTextStyles.figure(
                  _timeFont, FontWeight.w500, palette.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}

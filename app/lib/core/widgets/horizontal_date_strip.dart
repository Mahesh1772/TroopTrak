import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/app_motion.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';
import '../utils/date_formats.dart';

const _smallSize = 11.5;
const _smallTracking = 0.06;
const _dayLineHeight = 1.05;

/// One 54x72 tile per day from [firstDate] to [lastDate]; the selected day is
/// on the brand gradient and is scrolled to the middle.
class HorizontalDateStrip extends StatefulWidget {
  const HorizontalDateStrip({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<HorizontalDateStrip> createState() => _HorizontalDateStripState();
}

class _HorizontalDateStripState extends State<HorizontalDateStrip> {
  final _controller = ScrollController();

  double get _edge => AppSpacing.lg.w;

  double get _tileWidth => AppLayout.dateTile.width.w;

  double get _itemExtent => _tileWidth + AppSpacing.sm.w;

  int get _count => dayDifference(widget.lastDate, widget.firstDate) + 1;

  int _indexOf(DateTime date) => dayDifference(date, widget.firstDate);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected());
  }

  @override
  void didUpdateWidget(covariant HorizontalDateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected());
    }
  }

  void _centerSelected() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final tileMiddle =
        _edge + _indexOf(widget.selectedDate) * _itemExtent + _tileWidth / 2;
    final offset = tileMiddle - position.viewportDimension / 2;
    _controller.jumpTo(offset.clamp(0, position.maxScrollExtent));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppLayout.dateTile.height.h,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: _edge),
        itemExtent: _itemExtent,
        itemCount: _count,
        itemBuilder: (context, index) {
          final day = DateTime(
            widget.firstDate.year,
            widget.firstDate.month,
            widget.firstDate.day + index,
          );
          return Padding(
            padding: EdgeInsetsDirectional.only(end: AppSpacing.sm.w),
            child: _DayTile(
              key: ValueKey('date-strip-${formatDay(day)}'),
              day: day,
              selected: isSameDay(day, widget.selectedDate),
              onTap: () => widget.onDateSelected(day),
            ),
          );
        },
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    super.key,
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final small = selected ? AppColors.onGradientLabel : palette.secondaryText;
    final big = selected ? AppColors.white : palette.onCard;
    final radius = BorderRadius.circular(AppRadii.tile.r);
    TextStyle smallStyle() => AppTextStyles.barlow(
          _smallSize,
          FontWeight.w600,
          small,
        ).copyWith(letterSpacing: _smallSize.sp * _smallTracking);

    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        curve: AppMotion.ease,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: selected ? null : palette.card,
          gradient: selected
              ? LinearGradient(
                  colors: palette.headerGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 1,
              children: [
                Text(formatShortMonth(day).toUpperCase(), style: smallStyle()),
                Text(
                  '${day.day}',
                  style: AppTextStyles.figure(24, FontWeight.w600, big)
                      .copyWith(height: _dayLineHeight),
                ),
                Text(
                  formatShortWeekday(day).toUpperCase(),
                  style: smallStyle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

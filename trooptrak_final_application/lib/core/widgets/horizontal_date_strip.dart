import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';
import '../utils/date_formats.dart';

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
  static final _month = DateFormat('MMM', 'en_US');
  static final _weekday = DateFormat('E', 'en_US');

  final _controller = ScrollController();

  double get _itemExtent => 80.w + AppSpacing.sm.w;

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
    final offset = _indexOf(widget.selectedDate) * _itemExtent -
        (position.viewportDimension - _itemExtent) / 2;
    _controller.jumpTo(offset.clamp(0, position.maxScrollExtent));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final muted = text.bodyMedium?.color?.withValues(alpha: 0.54);
    return SizedBox(
      height: 110.h,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemExtent: _itemExtent,
        itemCount: _count,
        itemBuilder: (context, index) {
          final day = DateTime(
            widget.firstDate.year,
            widget.firstDate.month,
            widget.firstDate.day + index,
          );
          final selected = isSameDay(day, widget.selectedDate);
          final color = selected ? AppColors.white : null;
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm.w),
            child: Material(
              key: ValueKey('date-strip-${formatDay(day)}'),
              color: selected ? AppColors.brandIndigo : context.colors.primary,
              borderRadius: BorderRadius.circular(AppRadii.lg.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.lg.r),
                onTap: () => widget.onDateSelected(day),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_month.format(day),
                        style:
                            text.labelMedium?.copyWith(color: color ?? muted)),
                    Text('${day.day}',
                        style: text.displayMedium?.copyWith(color: color)),
                    Text(_weekday.format(day),
                        style:
                            text.titleMedium?.copyWith(color: color ?? muted)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

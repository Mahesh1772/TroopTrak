import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/state_tone.dart';
import '../../../../core/widgets/tally_strip.dart';
import '../../../attendance/domain/usecases/watch_month_presence.dart';
import '../providers/month_presence_provider.dart';

/// One tick per day of the month on the profile header, under
/// "October in camp  7 of 8 days". Today is ringed; later days are blank.
class MonthTally extends StatelessWidget {
  const MonthTally({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<MonthPresenceProvider>().state.dataOrNull;
    if (report == null) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.onGradientPanel,
        borderRadius: BorderRadius.circular(AppRadii.tile.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.control.w,
          AppSpacing.control.h,
          AppSpacing.control.w,
          AppSpacing.md.h,
        ),
        child: TallyStrip(
          onGradient: true,
          tickHeight: AppLayout.profileTick,
          groups: [
            TallyGroup(
              label: '${formatMonthName(report.month)} in camp',
              figure: '${report.presence.inCampDays} of '
                  '${report.presence.elapsed} days',
              ticks: _ticks(report),
            ),
          ],
        ),
      ),
    );
  }

  List<TallyTick> _ticks(MonthReport report) {
    final month = formatShortMonth(report.month);
    return [
      for (final (index, state) in report.presence.days.indexed)
        if (state == null)
          TallyTick.future(title: '${index + 1} $month', detail: 'upcoming')
        else
          TallyTick(
            tone: state.tone,
            title: '${index + 1} $month',
            detail: state.label,
            isSelf: index + 1 == report.today.day,
          ),
    ];
  }
}

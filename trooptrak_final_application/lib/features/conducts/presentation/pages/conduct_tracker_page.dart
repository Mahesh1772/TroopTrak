import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/horizontal_date_strip.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_view.dart';
import '../../domain/entities/conduct.dart';
import '../providers/conduct_tracker_provider.dart';
import '../widgets/conduct_tile.dart';
import '../widgets/participation_chart.dart';

/// Rebuild of `CMD/.../conduct_tracker_screen.dart`; [canManage] shows Add
/// Conduct (commander only).
class ConductTrackerPage extends StatelessWidget {
  const ConductTrackerPage({super.key, this.canManage = true});

  final bool canManage;

  Future<void> _pickDay(BuildContext context) async {
    final provider = context.read<ConductTrackerProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.day,
      firstDate: provider.firstDay,
      lastDate: provider.lastDay,
    );
    if (picked != null) provider.selectDay(picked);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConductTrackerProvider>();
    final text = context.textStyles;
    final muted = text.bodyMedium?.color?.withValues(alpha: 0.54);
    final horizontal = EdgeInsets.symmetric(horizontal: AppSpacing.xl.w);
    return ListView(
      padding: EdgeInsets.only(bottom: 30.h),
      children: [
        SizedBox(height: AppSpacing.xl.h),
        Padding(
          padding: horizontal,
          child: Row(
            children: [
              IconButton(
                key: const Key('pickConductDay'),
                iconSize: 45.sp,
                onPressed: () => _pickDay(context),
                icon: const Icon(Icons.date_range_rounded),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatLongDate(provider.today),
                        style: text.displaySmall?.copyWith(
                            color: muted, fontWeight: FontWeight.w400)),
                    Text('Today',
                        style: text.displayLarge
                            ?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              if (canManage)
                PrimaryButton(
                  key: const Key('addConduct'),
                  label: 'Add Conduct',
                  icon: Icons.add,
                  style: PrimaryButtonStyle.brand,
                  expand: false,
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.addConduct),
                ),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        Padding(
          padding: EdgeInsets.only(left: AppSpacing.xl.w),
          child: HorizontalDateStrip(
            firstDate: provider.firstDay,
            lastDate: provider.lastDay,
            selectedDate: provider.day,
            onDateSelected: provider.selectDay,
          ),
        ),
        SizedBox(height: 30.h),
        StateView<List<Conduct>>(
          state: provider.conducts,
          isEmpty: (c) => c.isEmpty,
          empty: const EmptyState(message: 'NO CONDUCTS FOR TODAY!'),
          builder: (context, conducts) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader('Participation Strength', padding: horizontal),
              SizedBox(height: AppSpacing.xl.h),
              Container(
                height: 450.h,
                padding: EdgeInsets.all(AppSpacing.lg.sp),
                child: ParticipationChart(
                    bars: provider.bars, maxY: provider.chartMax),
              ),
              SizedBox(height: AppSpacing.xl.h),
              SectionHeader('Conducts Completed / Ongoing',
                  padding: horizontal),
              for (var i = 0; i < conducts.length; i++)
                ConductTile(
                  conduct: conducts[i],
                  number: i + 1,
                  onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.conductDetails,
                      arguments: conducts[i].id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

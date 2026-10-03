import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_view.dart';
import '../../domain/entities/duty.dart';
import '../providers/upcoming_duties_provider.dart';
import 'duty_tile.dart';

/// Rebuild of `tabs/upcoming_duties.dart` (R14a). Edit and delete only when
/// [canManage]; delete now asks first.
class UpcomingDutiesTab extends StatelessWidget {
  const UpcomingDutiesTab({super.key, this.canManage = true});

  final bool canManage;

  Future<void> _pick(BuildContext context) async {
    final provider = context.read<UpcomingDutiesProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selected,
      firstDate: DateTime(2020),
      lastDate: DateTime(provider.today.year + 1, 12, 31),
    );
    if (picked != null) provider.select(picked);
  }

  Future<void> _delete(BuildContext context, Duty duty) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete this duty?',
      message: 'Every participant loses ${duty.points} points.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final error = await context.read<UpcomingDutiesProvider>().delete(duty);
    if (!context.mounted) return;
    AppSnackbar.outcome(context, error, success: 'Duty deleted');
  }

  List<Widget> _tiles(BuildContext context, UpcomingDutiesProvider provider,
      List<Duty> duties, String emptyMessage) {
    if (duties.isEmpty) return [EmptyState(message: emptyMessage)];
    return [
      for (final duty in duties)
        DutyTile(
          duty: duty,
          participating: provider.isParticipating(duty),
          onEdit: canManage
              ? () => Navigator.of(context)
                  .pushNamed(AppRoutes.editDuty, arguments: duty)
              : null,
          onDelete: canManage ? () => _delete(context, duty) : null,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UpcomingDutiesProvider>();
    final text = context.textStyles;
    final muted = text.bodyMedium?.color?.withValues(alpha: 0.54);
    final selected = provider.selected;
    return StateView<List<Duty>>(
      state: provider.state,
      builder: (context, _) => ListView(
        padding: EdgeInsets.only(top: 50.h, bottom: 50.h),
        children: [
          const SectionHeader("Today's Duties"),
          Container(
            margin: EdgeInsets.all(AppSpacing.lg.sp),
            padding: EdgeInsets.all(AppSpacing.lg.sp),
            decoration: BoxDecoration(
              border: Border.all(
                  width: 2.w,
                  color: AppColors.brandIndigo.withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(AppSpacing.lg.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  key: const Key('pickDutyDay'),
                  iconSize: 45.sp,
                  onPressed: () => _pick(context),
                  icon: const Icon(Icons.date_range_rounded),
                ),
                SizedBox(width: 30.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatLongDate(selected),
                        style: text.displayLarge?.copyWith(
                            color: muted, fontWeight: FontWeight.w400)),
                    Text(
                      isSameDay(selected, provider.today)
                          ? 'Today'
                          : formatWeekday(selected),
                      style: text.displayLarge?.copyWith(
                          fontSize: 32.sp, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ..._tiles(context, provider, provider.onSelectedDay,
              'NO DUTIES FOR TODAY!'),
          SizedBox(height: 50.h),
          const SectionHeader('Upcoming Duties'),
          ..._tiles(
              context, provider, provider.upcoming, 'NO UPCOMING DUTIES!'),
        ],
      ),
    );
  }
}

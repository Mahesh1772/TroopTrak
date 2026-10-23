import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/date_header.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/horizontal_date_strip.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_view.dart';
import '../../domain/entities/conduct.dart';
import '../providers/conduct_tracker_provider.dart';
import '../widgets/conduct_tile.dart';

/// Rebuild of `CMD/.../conduct_tracker_screen.dart` and, read-only, of
/// `P2/screens/conduct_tracker_screen/conduct_tracker_screen.dart`.
/// [canManage] shows Add Conduct and opens editable details; [showTitle]
/// heads the page where the shell has no app bar (soldier side).
class ConductTrackerPage extends StatelessWidget {
  const ConductTrackerPage({
    super.key,
    this.canManage = true,
    this.showTitle = false,
  });

  final bool canManage;
  final bool showTitle;

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
    return ListView(
      children: [
        if (showTitle)
          Container(
            height: AppLayout.appBarHeight.h,
            alignment: AlignmentDirectional.centerStart,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
            child: Text(
              'Conduct Tracker',
              style: AppTextStyles.pageTitle(context.colors.onSurface),
            ),
          ),
        DateHeader(
          date: provider.day,
          today: provider.today,
          pickerKey: const Key('pickConductDay'),
          onPickDate: () => _pickDay(context),
          action: canManage
              ? PrimaryButton(
                  key: const Key('addConduct'),
                  label: 'Add Conduct',
                  icon: Icons.add,
                  style: PrimaryButtonStyle.tonal,
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.addConduct),
                )
              : null,
        ),
        HorizontalDateStrip(
          firstDate: provider.firstDay,
          lastDate: provider.lastDay,
          selectedDate: provider.day,
          onDateSelected: provider.selectDay,
        ),
        StateView<List<Conduct>>(
          state: provider.conducts,
          isEmpty: (c) => c.isEmpty,
          empty: const EmptyState(
            message: 'NO CONDUCTS FOR TODAY!',
            icon: Icons.event_busy_rounded,
          ),
          builder: (context, conducts) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                'Conducts Completed / Ongoing',
                caption: '${conducts.length} today',
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg.w,
                  0,
                  AppSpacing.lg.w,
                  AppSpacing.xxl.h,
                ),
                child: AppListCard(
                  dividerInset: 0,
                  children: [
                    for (final conduct in conducts)
                      ConductTile(
                        conduct: conduct,
                        ticks: provider.ticksFor(conduct),
                        participating: provider.isParticipating(conduct),
                        onTap: () => Navigator.of(context).pushNamed(
                          canManage
                              ? AppRoutes.conductDetails
                              : AppRoutes.conductDetailsReadOnly,
                          arguments: conduct.id,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

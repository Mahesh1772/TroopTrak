import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/date_header.dart';
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

  Widget _section(
    BuildContext context,
    UpcomingDutiesProvider provider, {
    required String title,
    required List<Duty> duties,
    required String emptyMessage,
    bool first = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title,
          caption: '${duties.length}',
          padding: first
              ? EdgeInsets.fromLTRB(
                  AppSpacing.xl.w,
                  0,
                  AppSpacing.xl.w,
                  AppLayout.sectionBottom.h,
                )
              : null,
        ),
        if (duties.isEmpty)
          EmptyState(message: emptyMessage)
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
            child: Column(
              spacing: AppSpacing.md.h,
              children: [
                for (final duty in duties)
                  DutyTile(
                    duty: duty,
                    participating: provider.isParticipating(duty),
                    isSelf: provider.isSelf,
                    onEdit: canManage
                        ? () => Navigator.of(context)
                            .pushNamed(AppRoutes.editDuty, arguments: duty)
                        : null,
                    onDelete: canManage ? () => _delete(context, duty) : null,
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UpcomingDutiesProvider>();
    return StateView<List<Duty>>(
      state: provider.state,
      builder: (context, _) => ListView(
        padding: EdgeInsets.only(
          top: AppSpacing.lg.h,
          bottom: AppLayout.listFabClearance.h,
        ),
        children: [
          DateHeader(
            date: provider.selected,
            today: provider.today,
            pickerKey: const Key('pickDutyDay'),
            onPickDate: () => _pick(context),
          ),
          _section(
            context,
            provider,
            title: "Today's Duties",
            duties: provider.onSelectedDay,
            emptyMessage: 'NO DUTIES FOR TODAY!',
            first: true,
          ),
          _section(
            context,
            provider,
            title: 'Upcoming Duties',
            duties: provider.upcoming,
            emptyMessage: 'NO UPCOMING DUTIES!',
          ),
        ],
      ),
    );
  }
}

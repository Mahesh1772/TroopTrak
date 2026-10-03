import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../pages/edit_attendance_page.dart';
import '../providers/attendance_provider.dart';

/// Rebuild of `attendance_tab_detailed_screen.dart` (R11 order).
class AttendanceTab extends StatelessWidget {
  const AttendanceTab({super.key, required this.canManage});

  final bool canManage;

  Future<void> _delete(BuildContext context, AttendanceRecord record) async {
    final error = await context.read<AttendanceProvider>().delete(record);
    if (!context.mounted) return;
    AppSnackbar.outcome(context, error, success: 'Attendance record deleted');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AttendanceProvider>().state;
    return StateView<List<AttendanceRecord>>(
      state: state,
      builder: (context, records) => ListView(
        padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, AppSpacing.xxxl.h),
        children: [
          SectionHeader('Book In / Book Out',
              icon: Icons.outbond,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h)),
          if (records.isEmpty)
            const EmptyState(message: 'No attendance records', image: null),
          for (final record in records)
            AttendanceTile(
              record: record,
              onEdit: canManage
                  ? () => Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => EditAttendancePage(record: record),
                      ))
                  : null,
              onDelete: canManage ? () => _delete(context, record) : null,
            ),
        ],
      ),
    );
  }
}

/// Rebuild of `book_in_out_tile.dart`.
class AttendanceTile extends StatelessWidget {
  const AttendanceTile({
    super.key,
    required this.record,
    this.onEdit,
    this.onDelete,
  });

  final AttendanceRecord record;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final radius = Radius.circular(AppRadii.lg.r);
    final inside = record.isInsideCamp;
    final manageable = onEdit != null || onDelete != null;
    final tile = Container(
      decoration: BoxDecoration(
        color: inside ? AppColors.bookIn : AppColors.danger,
        borderRadius: manageable
            ? BorderRadius.horizontal(left: radius)
            : BorderRadius.all(radius),
      ),
      padding: EdgeInsets.all(AppSpacing.lg.sp),
      child: Row(
        children: [
          Icon(inside ? Icons.work_history : Icons.home,
              color: AppColors.white, size: 25.sp),
          SizedBox(width: 15.w),
          SizedBox(
            width: 80.w,
            child: AutoSizeText(inside ? 'BOOK IN' : 'BOOKOUT',
                maxLines: 1,
                style: text.headlineMedium?.copyWith(color: AppColors.white)),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: AutoSizeText(attendanceDisplay(record.timestamp),
                maxLines: 1,
                style: text.headlineSmall?.copyWith(color: AppColors.white)),
          ),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: !manageable
          ? tile
          : Slidable(
              key: Key('attendance-${record.id}'),
              endActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    key: Key('editAttendance-${record.id}'),
                    onPressed: (_) => onEdit?.call(),
                    icon: Icons.pending_actions_outlined,
                    backgroundColor: AppColors.info,
                    foregroundColor: AppColors.white,
                  ),
                  SlidableAction(
                    key: Key('deleteAttendance-${record.id}'),
                    onPressed: (_) => onDelete?.call(),
                    icon: Icons.delete_forever_rounded,
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.white,
                    borderRadius: BorderRadius.horizontal(right: radius),
                  ),
                ],
              ),
              child: tile,
            ),
    );
  }
}

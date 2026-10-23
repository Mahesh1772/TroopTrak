import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/icon_plate.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/slidable_row.dart';
import '../../../../core/widgets/state_tone.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../pages/edit_attendance_page.dart';
import '../providers/attendance_provider.dart';

/// Book in and book out rows, newest first. Read-only when [canManage] is false.
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
        padding: EdgeInsets.only(bottom: AppSpacing.xxxl.h),
        children: [
          const SectionHeader('Book In / Book Out', caption: 'Newest first'),
          if (records.isEmpty)
            const EmptyState(message: 'No attendance records')
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
              child: AppListCard(
                children: [
                  for (final record in records)
                    AttendanceTile(
                      record: record,
                      onEdit: canManage
                          ? () => Navigator.of(context)
                                  .push(MaterialPageRoute<void>(
                                builder: (_) =>
                                    EditAttendancePage(record: record),
                              ))
                          : null,
                      onDelete:
                          canManage ? () => _delete(context, record) : null,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One book in or book out row: an icon plate, the label and a tabular
/// timestamp. Slides to edit and delete when the callbacks are given.
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
    final palette = context.palette;
    final inside = record.isInsideCamp;
    final tone = inside ? StateTone.inCamp : StateTone.leave;
    return SlidableRow(
      key: Key('attendance-${record.id}'),
      onEdit: onEdit,
      onDelete: onDelete,
      editKey: Key('editAttendance-${record.id}'),
      deleteKey: Key('deleteAttendance-${record.id}'),
      child: AppListRow(
        title: inside ? 'BOOK IN' : 'BOOKOUT',
        titleStyle: AppTextStyles.rowLabel(tone.text(palette)),
        leading: IconPlate(
          inside ? Icons.work_history_rounded : Icons.home_rounded,
          tone: tone,
        ),
        subtitle: Text(
          attendanceDisplay(record.timestamp),
          style: AppTextStyles.figure(15, FontWeight.w500, palette.onCard),
        ),
      ),
    );
  }
}

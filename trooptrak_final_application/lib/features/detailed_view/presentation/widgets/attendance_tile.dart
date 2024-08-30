import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceTile extends StatelessWidget {
  final AttendanceRecord record;
  final Function(AttendanceRecord) onEdit;
  final Function(String) onDelete;

  const AttendanceTile({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInsideCamp = record.isInsideCamp;
    final Color tileColor = isInsideCamp ? Colors.green.shade600 : Colors.red;
    final IconData tileIcon = isInsideCamp ? Icons.work_history : Icons.home;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onEdit(record),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.pending_actions_outlined,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) => onDelete(record.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete_forever_rounded,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              bottomLeft: Radius.circular(12.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  tileIcon,
                  color: Colors.white,
                  size: 30.sp,
                ),
                SizedBox(width: 20.w),
                SizedBox(
                  width: 100.w,
                  child: AutoSizeText(
                    isInsideCamp ? "BOOK IN" : "BOOK OUT",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: Colors.white,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 20.w),
                SizedBox(
                  width: 180.w,
                  child: AutoSizeText(
                    record.dateTime,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

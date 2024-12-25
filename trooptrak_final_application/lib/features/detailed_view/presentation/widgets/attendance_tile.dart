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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(record),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(record.id),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(12.r),
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => onEdit(record),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? const Color.fromARGB(255, 45, 50, 65)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
                spreadRadius: isDarkMode ? 1.r : 0.r,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.dateTime,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDarkMode 
                          ? Colors.white
                          : theme.colorScheme.tertiary,
                      letterSpacing: 1.2,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    record.isInsideCamp ? 'Inside Camp' : 'Outside Camp',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: record.isInsideCamp
                          ? (isDarkMode ? const Color.fromARGB(255, 130, 100, 255) : theme.colorScheme.secondary)
                          : (isDarkMode ? const Color.fromARGB(255, 255, 100, 100) : theme.colorScheme.error),
                      letterSpacing: 1.2,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: record.isInsideCamp
                          ? (isDarkMode ? const Color.fromARGB(255, 130, 100, 255) : theme.colorScheme.secondary)
                          : (isDarkMode ? const Color.fromARGB(255, 255, 100, 100) : theme.colorScheme.error),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      record.isInsideCamp
                          ? Icons.check_circle_outline_rounded
                          : Icons.cancel_outlined,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.tertiary.withOpacity(0.5),
                    size: 24.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

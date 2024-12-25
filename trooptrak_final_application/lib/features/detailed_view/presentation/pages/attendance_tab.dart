import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../nominal_roll/domain/entities/attendance_record.dart' as nominal_roll;
import '../../domain/entities/attendance_record.dart' as detailed_view;
import '../../../nominal_roll/presentation/providers/user_detail_provider.dart';
import 'edit_attendance_page.dart';

class AttendanceTab extends StatelessWidget {
  final String userId;

  const AttendanceTab({super.key, required this.userId});

  void _navigateToEdit(BuildContext context, nominal_roll.AttendanceRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAttendancePage(
          userId: userId,
          record: detailed_view.AttendanceRecord(
            id: DateTime.now().toString(), // Generate a temporary ID
            dateTime: record.dateTime,
            isInsideCamp: record.isInsideCamp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<UserDetailProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<List<nominal_roll.AttendanceRecord>>(
            stream: provider.getUserAttendance(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.secondary,
                    strokeWidth: 2.w,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                      letterSpacing: 1.2,
                      fontSize: 14.sp,
                    ),
                  ),
                );
              }

              final records = snapshot.data ?? [];
              if (records.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 32.sp,
                        color: theme.colorScheme.error,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No attendance records found',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.tertiary,
                          letterSpacing: 1.2,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? const Color.fromARGB(255, 45, 50, 65)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode 
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.outbond,
                              size: 20.sp,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "Book In / Book Out",
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.tertiary,
                              letterSpacing: 1.2,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: records.length,
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) => _navigateToEdit(context, record),
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit_rounded,
                                  label: 'Edit',
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(12.r),
                                  ),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () => _navigateToEdit(context, record),
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
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

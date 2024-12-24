import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'edit_attendance_page.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_tile.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceTab extends StatelessWidget {
  final String userId;

  const AttendanceTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.all(30.0.sp),
          child: StreamBuilder<List<AttendanceRecord>>(
            stream: provider.getUserAttendanceStream(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final attendanceRecords = snapshot.data ?? [];
              if (attendanceRecords.isEmpty) {
                return const Center(
                    child: Text('No attendance records found.'));
              }
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.outbond,
                          size: 30.sp,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(
                          "Book In / Book Out",
                          maxLines: 2,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.sp,
                                    letterSpacing: 1.5,
                                  ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 650.h,
                      child: ListView.builder(
                        itemCount: attendanceRecords.length,
                        itemBuilder: (context, index) {
                          final record = attendanceRecords[index];
                          return AttendanceTile(
                            record: record,
                            onEdit: (record) =>
                                _navigateToEditPage(context, provider, record),
                            onDelete: (recordId) => _showDeleteConfirmation(
                                context, provider, recordId),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToEditPage(BuildContext context, AttendanceProvider provider,
      AttendanceRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditAttendancePage(
          userId: userId,
          record: record,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, AttendanceProvider provider, String recordId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Attendance Record'),
          content: const Text(
              'Are you sure you want to delete this attendance record?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                provider.deleteAttendanceRecord(userId, recordId).listen(
                  (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Attendance record deleted successfully')),
                    );
                    Navigator.of(context).pop();
                  },
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error deleting attendance record: $error')),
                    );
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

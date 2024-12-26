import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/features/detailed_view/presentation/widgets/attendance_tile.dart';
import '../../domain/entities/attendance_record.dart' as detailed_view;
import '../../../nominal_roll/presentation/providers/user_detail_provider.dart';
import '../providers/attendance_provider.dart';
import 'edit_attendance_page.dart';

class AttendanceTab extends StatelessWidget {
  final String userId;

  const AttendanceTab({super.key, required this.userId});

  void _navigateToEdit(BuildContext context, detailed_view.AttendanceRecord record) {
    print("Original record datetime: ${record.dateTime}");
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAttendancePage(
          userId: userId,
          record: record,
        ),
      ),
    );
  }

  void _deleteRecord(BuildContext context, String recordId) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    attendanceProvider.deleteAttendanceRecord(userId, recordId).listen(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance record deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting attendance record: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<UserDetailProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<List<detailed_view.AttendanceRecord>>(
            stream: provider.getUserAttendance(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No attendance records found'));
              }

              final records = snapshot.data!.toList()..sort((a, b) => b.dateTime.compareTo(a.dateTime));
              return ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return AttendanceTile(
                    record: record,
                    onEdit: (record) => _navigateToEdit(context, record),
                    onDelete: (recordId) => _deleteRecord(context, recordId),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

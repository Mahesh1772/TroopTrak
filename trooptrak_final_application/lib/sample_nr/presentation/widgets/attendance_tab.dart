import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_detail_provider.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceTab extends StatelessWidget {
  final String userId;

  const AttendanceTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDetailProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<AttendanceRecord>>(
          stream: provider.getUserAttendance(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final attendanceRecords = snapshot.data ?? [];

            if (attendanceRecords.isEmpty) {
              return const Center(child: Text('No attendance records found.'));
            }

            return ListView.builder(
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                final record = attendanceRecords[index];
                return ListTile(
                  title: Text(record.dateTime),
                  subtitle: Text(record.isInsideCamp ? 'Inside Camp' : 'Outside Camp'),
                  leading: Icon(
                    record.isInsideCamp ? Icons.check_circle : Icons.cancel,
                    color: record.isInsideCamp ? Colors.green : Colors.red,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
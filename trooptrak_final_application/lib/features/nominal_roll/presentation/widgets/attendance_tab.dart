import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
                return buildAttendanceTile(record);
              },
            );
          },
        );
      },
    );
  }

  Widget buildAttendanceTile(AttendanceRecord record) {
    final bool isInsideCamp = record.isInsideCamp;
    final Color tileColor = isInsideCamp ? Colors.green.shade600 : Colors.red;
    final IconData tileIcon = isInsideCamp ? Icons.work_history : Icons.home;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                tileIcon,
                color: Colors.white,
                size: 25,
              ),
              const SizedBox(width: 15),
              SizedBox(
                width: 80,
                child: Text(
                  isInsideCamp ? "BOOK IN" : "BOOK OUT",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  record.dateTime,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
    );
  }
}

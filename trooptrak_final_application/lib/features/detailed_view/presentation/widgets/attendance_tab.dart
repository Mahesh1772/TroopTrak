// lib/features/attendance/presentation/pages/attendance_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
        return StreamBuilder<List<AttendanceRecord>>(
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
              return const Center(child: Text('No attendance records found.'));
            }
            return ListView.builder(
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                final record = attendanceRecords[index];
                return AttendanceTile(
                  record: record,
                  onEdit: (record) => _showEditDialog(context, provider, record),
                  onDelete: (recordId) => _showDeleteConfirmation(context, provider, recordId),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, AttendanceProvider provider, AttendanceRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDateTime = DateTime.parse(record.dateTime);
        bool isInsideCamp = record.isInsideCamp;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Attendance Record'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Date and Time'),
                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        );
                        if (time != null) {
                          setState(() {
                            selectedDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Status'),
                    subtitle: Text(isInsideCamp ? 'Inside Camp' : 'Outside Camp'),
                    value: isInsideCamp,
                    onChanged: (bool value) {
                      setState(() {
                        isInsideCamp = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    final updatedRecord = AttendanceRecord(
                      id: record.id,
                      dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime),
                      isInsideCamp: isInsideCamp,
                    );
                    provider.updateAttendanceRecord(userId, updatedRecord);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, AttendanceProvider provider, String recordId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Attendance Record'),
          content: const Text('Are you sure you want to delete this attendance record?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                provider.deleteAttendanceRecord(userId, recordId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/attendance_record.dart';
import '../providers/attendance_provider.dart';
import 'package:provider/provider.dart';

class EditAttendancePage extends StatefulWidget {
  final String userId;
  final AttendanceRecord record;

  const EditAttendancePage({
    super.key,
    required this.userId,
    required this.record,
  });

  @override
  _EditAttendancePageState createState() => _EditAttendancePageState();
}

class _EditAttendancePageState extends State<EditAttendancePage> {
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateFormat("EEE d MMM yyyy HH:mm:ss").parse(widget.record.dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Attendance Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display record type (non-editable)
            ListTile(
              title: const Text('Record Type'),
              subtitle: Text(
                widget.record.isInsideCamp ? 'Book In' : 'Book Out',
                style: TextStyle(
                  color: widget.record.isInsideCamp ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            // Date and time selector
            ListTile(
              title: const Text('Date and Time'),
              subtitle: Text(
                DateFormat('EEE d MMM yyyy HH:mm:ss').format(selectedDateTime)
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateTime,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
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
  }

  void _saveChanges() {
    final updatedRecord = AttendanceRecord(
      id: widget.record.id,
      dateTime: DateFormat('EEE d MMM yyyy HH:mm:ss').format(selectedDateTime),
      isInsideCamp: widget.record.isInsideCamp, // Maintain original status
    );
    
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    attendanceProvider.updateAttendanceRecord(widget.userId, updatedRecord).listen(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance record updated successfully')),
        );
        Navigator.of(context).pop();
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating attendance record: $error')),
        );
      },
    );
  }
}

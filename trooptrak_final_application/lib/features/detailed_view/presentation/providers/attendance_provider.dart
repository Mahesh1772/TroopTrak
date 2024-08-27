import 'package:flutter/foundation.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/usecases/get_user_attendance.dart';
import '../../domain/usecases/update_attendance.dart';
import '../../domain/usecases/delete_attendance.dart';

class AttendanceProvider extends ChangeNotifier {
  final GetUserAttendance getUserAttendance;
  final UpdateAttendance updateAttendance;
  final DeleteAttendance deleteAttendance;

  AttendanceProvider({
    required this.getUserAttendance,
    required this.updateAttendance,
    required this.deleteAttendance,
  });

  Stream<List<AttendanceRecord>> getUserAttendanceStream(String userId) {
    return getUserAttendance(userId);
  }

  Future<void> updateAttendanceRecord(String userId, AttendanceRecord record) async {
    await updateAttendance(userId, record);
  }

  Future<void> deleteAttendanceRecord(String userId, String recordId) async {
    await deleteAttendance(userId, recordId);
  }
}
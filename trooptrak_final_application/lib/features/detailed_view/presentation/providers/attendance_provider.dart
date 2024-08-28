import 'package:flutter/foundation.dart';
import 'package:trooptrak_final_application/features/detailed_view/domain/usecases/update_attendance.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/usecases/get_user_attendance.dart';
import '../../domain/usecases/update_user_attendance.dart';
import '../../domain/usecases/delete_attendance.dart';

class AttendanceProvider extends ChangeNotifier {
  final GetUserAttendance getUserAttendance;
  final UpdateAttendance updateAttendance;
  final DeleteAttendance deleteAttendance;
  final UpdateUserAttendance updateUserAttendance;

  AttendanceProvider({
    required this.getUserAttendance,
    required this.updateAttendance,
    required this.deleteAttendance,
    required this.updateUserAttendance,
  });

  Stream<List<AttendanceRecord>> getUserAttendanceStream(String userId) {
    return getUserAttendance(userId);
  }

  Stream<void> updateAttendanceRecord(String userId, AttendanceRecord record) {
    return updateAttendance(userId, record);
  }

  Stream<void> deleteAttendanceRecord(String userId, String recordId) {
    return deleteAttendance(userId, recordId);
  }

  Stream<void> updateUserAttendanceRecord(String userId, bool isInsideCamp) {
    return updateUserAttendance(userId, isInsideCamp);
  }
}

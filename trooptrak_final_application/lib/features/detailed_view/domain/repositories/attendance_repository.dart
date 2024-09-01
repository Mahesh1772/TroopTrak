import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Stream<List<AttendanceRecord>> getUserAttendance(String userId);
  Stream<void> updateAttendance(String userId, AttendanceRecord record);
  Stream<void> deleteAttendance(String userId, String recordId);
  Stream<void> updateUserAttendance(String userId, bool isInsideCamp);
  Stream<void> updateAttendanceAndUserStatus(String userId, AttendanceRecord record, bool isInsideCamp);
}

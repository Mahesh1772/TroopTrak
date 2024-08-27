import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Stream<List<AttendanceRecord>> getUserAttendance(String userId);
  Future<void> updateAttendance(String userId, AttendanceRecord record);
  Future<void> deleteAttendance(String userId, String recordId);
}
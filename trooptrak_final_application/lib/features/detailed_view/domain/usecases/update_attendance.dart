import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class UpdateAttendance {
  final AttendanceRepository repository;

  UpdateAttendance(this.repository);

  Future<void> call(String userId, AttendanceRecord record) {
    return repository.updateAttendance(userId, record);
  }
}
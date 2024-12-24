import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class UpdateAttendance {
  final AttendanceRepository repository;

  UpdateAttendance(this.repository);

  Stream<void> call(String userId, AttendanceRecord record) {
    return repository.updateAttendanceAndUserStatus(userId, record, record.isInsideCamp);
  }
}

import '../repositories/attendance_repository.dart';

class DeleteAttendance {
  final AttendanceRepository repository;

  DeleteAttendance(this.repository);

  Stream<void> call(String userId, String recordId) {
    return repository.deleteAttendance(userId, recordId);
  }
}

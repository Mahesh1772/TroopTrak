import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class GetUserAttendance {
  final AttendanceRepository repository;

  GetUserAttendance(this.repository);

  Stream<List<AttendanceRecord>> call(String userId) {
    return repository.getUserAttendance(userId);
  }
}

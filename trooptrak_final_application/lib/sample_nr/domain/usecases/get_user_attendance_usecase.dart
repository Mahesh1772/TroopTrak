import '../entities/attendance_record.dart';
import '../repositories/user_repository.dart';

class GetUserAttendanceUseCase {
  final UserRepository repository;

  GetUserAttendanceUseCase(this.repository);

  Stream<List<AttendanceRecord>> call(String id) {
    return repository.getUserAttendance(id);
  }
}

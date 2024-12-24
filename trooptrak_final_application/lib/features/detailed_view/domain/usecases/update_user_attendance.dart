import '../repositories/attendance_repository.dart';

class UpdateUserAttendance {
  final AttendanceRepository repository;

  UpdateUserAttendance(this.repository);

  Stream<void> call(String userId, bool isInsideCamp) {
    return repository.updateUserAttendance(userId, isInsideCamp);
  }
}

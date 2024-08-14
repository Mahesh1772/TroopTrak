import '../repositories/user_repository.dart';

class UpdateUserAttendanceUseCase {
  final UserRepository repository;

  UpdateUserAttendanceUseCase(this.repository);

  Future<void> call(String id, bool isInsideCamp) {
    return repository.updateUserAttendance(id, isInsideCamp);
  }
}

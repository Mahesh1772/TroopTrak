import '../entities/status.dart';
import '../repositories/status_repository.dart';

class UpdateStatusUseCase {
  final StatusRepository repository;

  UpdateStatusUseCase(this.repository);

  Future<void> call(String userId, Status status) async {
    await repository.updateStatus(userId, status);
  }
}

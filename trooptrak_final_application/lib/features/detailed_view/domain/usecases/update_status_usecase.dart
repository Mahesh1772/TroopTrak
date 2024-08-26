import '../entities/status.dart';
import '../repositories/status_repository.dart';

class UpdateStatusUseCase {
  final StatusRepository repository;

  UpdateStatusUseCase(this.repository);

  Stream<void> call(String userId, Status status) {
    return repository.updateStatus(userId, status);
  }
}

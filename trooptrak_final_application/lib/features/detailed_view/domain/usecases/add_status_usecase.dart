import '../entities/status.dart';
import '../repositories/status_repository.dart';

class AddStatusUseCase {
  final StatusRepository repository;

  AddStatusUseCase(this.repository);

  Stream<void> call(String userId, Status status) {
    return repository.addStatus(userId, status);
  }
}

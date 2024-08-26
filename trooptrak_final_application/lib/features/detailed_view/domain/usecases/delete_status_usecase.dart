import '../repositories/status_repository.dart';

class DeleteStatusUseCase {
  final StatusRepository repository;

  DeleteStatusUseCase(this.repository);

  Stream<void> call(String userId, String statusId) {
    return repository.deleteStatus(userId, statusId);
  }
}

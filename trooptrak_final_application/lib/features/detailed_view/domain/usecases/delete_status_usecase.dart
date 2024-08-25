import '../repositories/status_repository.dart';

class DeleteStatusUseCase {
  final StatusRepository repository;

  DeleteStatusUseCase(this.repository);

  Future<void> call(String userId, String statusId) async {
    await repository.deleteStatus(userId, statusId);
  }
}

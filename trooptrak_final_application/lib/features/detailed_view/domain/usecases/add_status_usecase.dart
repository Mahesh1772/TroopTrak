import '../entities/status.dart';
import '../repositories/status_repository.dart';

class AddStatusUseCase {
  final StatusRepository repository;

  AddStatusUseCase(this.repository);

  Future<void> call(String userId, Status status) async {
    await repository.addStatus(userId, status);
  }
}

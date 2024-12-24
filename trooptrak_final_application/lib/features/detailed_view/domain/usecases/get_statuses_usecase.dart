import '../entities/status.dart';
import '../repositories/status_repository.dart';

class GetStatusesUseCase {
  final StatusRepository repository;

  GetStatusesUseCase(this.repository);

  Stream<List<Status>> call(String userId) {
    return repository.getStatuses(userId);
  }
}

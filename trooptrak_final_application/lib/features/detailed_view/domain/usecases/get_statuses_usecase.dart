import '../entities/status.dart';
import '../repositories/status_repository.dart';

class GetStatusesUseCase {
  final StatusRepository repository;

  GetStatusesUseCase(this.repository);

  Future<List<Status>> call(String userId) async {
    return await repository.getStatuses(userId);
  }
}

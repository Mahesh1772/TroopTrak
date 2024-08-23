import '../entities/status.dart';
import '../repositories/user_repository.dart';

class GetUserStatusesUseCase {
  final UserRepository repository;

  GetUserStatusesUseCase(this.repository);

  Stream<List<Status>> call(String id) {
    return repository.getUserStatuses(id);
  }
}

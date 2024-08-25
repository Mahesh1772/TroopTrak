import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Stream<User> call(String id) {
    return repository.getUserById(id);
  }
}

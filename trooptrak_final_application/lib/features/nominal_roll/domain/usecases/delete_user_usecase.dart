import 'package:dartz/dartz.dart';
import '../repositories/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository repository;

  DeleteUserUseCase(this.repository);

  Future<Either<String, void>> call(String userId) {
    return repository.deleteUser(userId);
  }
}

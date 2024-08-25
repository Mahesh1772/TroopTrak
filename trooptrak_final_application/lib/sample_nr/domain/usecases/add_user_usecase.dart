import 'package:dartz/dartz.dart';
import '../entities/scanned_soldier.dart';
import '../repositories/user_repository.dart';

class AddUserUseCase {
  final UserRepository repository;

  AddUserUseCase(this.repository);

  Future<Either<String, void>> call(ScannedSoldier soldier) {
    return repository.addUser(soldier);
  }
}

import '../repositories/conduct_repository.dart';

class DeleteConductUseCase {
  final ConductRepository repository;

  DeleteConductUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteConduct(id);
  }
} 
import '../entities/conduct.dart';
import '../repositories/conduct_repository.dart';

class UpdateConductUseCase {
  final ConductRepository repository;

  UpdateConductUseCase(this.repository);

  Future<void> call(Conduct conduct) {
    return repository.updateConduct(conduct);
  }
} 
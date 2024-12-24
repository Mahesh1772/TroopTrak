import '../entities/conduct.dart';
import '../repositories/conduct_repository.dart';

class AddConductUseCase {
  final ConductRepository repository;

  AddConductUseCase(this.repository);

  Future<void> call(Conduct conduct) {
    return repository.addConduct(conduct);
  }
} 
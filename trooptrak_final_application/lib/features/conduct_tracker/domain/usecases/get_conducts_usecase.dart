import '../entities/conduct.dart';
import '../repositories/conduct_repository.dart';

class GetConductsUseCase {
  final ConductRepository repository;

  GetConductsUseCase(this.repository);

  Stream<List<Conduct>> call() {
    return repository.getConducts();
  }
} 
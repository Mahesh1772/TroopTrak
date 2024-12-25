import '../repositories/conduct_repository.dart';
import '../entities/conduct.dart';

class GetConductByIdUseCase {
  final ConductRepository _repository;

  GetConductByIdUseCase(this._repository);

  Stream<Conduct> execute(String id) {
    return _repository.getConductById(id);
  }
}
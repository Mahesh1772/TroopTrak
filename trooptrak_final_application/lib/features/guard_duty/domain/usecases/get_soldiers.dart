import '../entities/soldier.dart';
import '../repositories/soldier_repository.dart';

class GetSoldiersUseCase {
  final SoldierRepository repository;

  GetSoldiersUseCase(this.repository);

  Future<List<Soldier>> call() async {
    return await repository.getSoldiers();
  }
} 
import '../entities/soldier.dart';

abstract class SoldierRepository {
  Future<List<Soldier>> getSoldiers();
} 
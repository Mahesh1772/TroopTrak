import '../entities/conduct.dart';

abstract class ConductRepository {
  Stream<List<Conduct>> getConducts();
  Future<void> addConduct(Conduct conduct);
  Future<void> updateConduct(Conduct conduct);
  Future<void> deleteConduct(String id);
  Stream<Conduct> getConductById(String id);
} 
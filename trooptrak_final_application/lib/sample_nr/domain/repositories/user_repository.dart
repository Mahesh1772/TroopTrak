import 'package:dartz/dartz.dart';
import 'package:trooptrak_final_application/sample_nr/domain/entities/scanned_soldier.dart';

import '../entities/user.dart';

abstract class UserRepository {
  Stream<List<User>> getUsers();
  Future<void> updateUserAttendance(String id, bool isInsideCamp);
  Future<Either<String, void>> addUser(ScannedSoldier soldier);
}

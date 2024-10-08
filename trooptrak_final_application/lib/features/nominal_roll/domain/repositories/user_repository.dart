import 'package:dartz/dartz.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/entities/scanned_soldier.dart';
import '../entities/user.dart';
import '../entities/attendance_record.dart';
import '../entities/status.dart';

abstract class UserRepository {
  Stream<List<User>> getUsers();
  Future<void> updateUserAttendance(String id, bool isInsideCamp);
  Future<Either<String, void>> addUser(ScannedSoldier soldier);
  Stream<User> getUserById(String id);
  Stream<List<AttendanceRecord>> getUserAttendance(String id);
  Stream<List<Status>> getUserStatuses(String id);
}

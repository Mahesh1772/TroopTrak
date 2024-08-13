import '../entities/user.dart';

abstract class UserRepository {
  Stream<List<User>> getUsers();
  Future<void> updateUserAttendance(String id, bool isInsideCamp);
}
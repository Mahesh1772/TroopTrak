import '../entities/user.dart';

abstract class UserRepository {
  Stream<List<User>> getUsers();
}
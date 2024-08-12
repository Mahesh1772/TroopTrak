import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_users_usecase.dart';

class UserProvider extends ChangeNotifier {
  final GetUsersUseCase getUsersUseCase;

  UserProvider({required this.getUsersUseCase});

  Stream<List<User>> get users => getUsersUseCase();
}
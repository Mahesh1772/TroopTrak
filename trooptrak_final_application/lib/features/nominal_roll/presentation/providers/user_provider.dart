import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/update_user_attendance_usecase.dart';

class UserProvider extends ChangeNotifier {
  final GetUsersUseCase getUsersUseCase;
  final UpdateUserAttendanceUseCase updateUserAttendanceUseCase;

  UserProvider({
    required this.getUsersUseCase,
    required this.updateUserAttendanceUseCase,
  });

  Stream<List<User>> get users => getUsersUseCase();

  Future<void> updateUserAttendance(String id, bool isInsideCamp) async {
    await updateUserAttendanceUseCase(id, isInsideCamp);
    notifyListeners();
  }
}
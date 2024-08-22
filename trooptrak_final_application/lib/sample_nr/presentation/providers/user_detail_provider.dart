import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/status.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/get_user_attendance_usecase.dart';
import '../../domain/usecases/get_user_statuses_usecase.dart';

class UserDetailProvider extends ChangeNotifier {
  final GetUserByIdUseCase getUserByIdUseCase;
  final GetUserAttendanceUseCase getUserAttendanceUseCase;
  final GetUserStatusesUseCase getUserStatusesUseCase;

  UserDetailProvider({
    required this.getUserByIdUseCase,
    required this.getUserAttendanceUseCase,
    required this.getUserStatusesUseCase,
  });

  User? _user;
  User? get user => _user;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadUser(String id) async {
    _isLoading = true;
    _user = null; // Reset user data
    notifyListeners();

    try {
      _user = await getUserByIdUseCase(id);
    } catch (e) {
      print('Error loading user: $e');
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<AttendanceRecord>> getUserAttendance(String id) {
    return getUserAttendanceUseCase(id);
  }

  Stream<List<Status>> getUserStatuses(String id) {
    return getUserStatusesUseCase(id);
  }
}
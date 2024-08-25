import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/status.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/get_user_attendance_usecase.dart';
import '../../domain/usecases/get_user_statuses_usecase.dart';

import 'dart:async';

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

  Completer<void>? _loadingCompleter;
  bool _initialDataLoaded = false;

  void loadUser(String id) {
    _isLoading = true;
    _initialDataLoaded = false;
    _loadingCompleter = Completer<void>();
    notifyListeners();

    getUserByIdUseCase(id).listen(
      (user) {
        _user = user;
        _isLoading = false;
        if (!_initialDataLoaded) {
          _initialDataLoaded = true;
          _loadingCompleter?.complete();
        }
        notifyListeners();
      },
      onError: (error) {
        print('Error loading user: $error');
        _isLoading = false;
        if (!_initialDataLoaded) {
          _initialDataLoaded = true;
          _loadingCompleter?.completeError(error);
        }
        notifyListeners();
      },
    );
  }

  Future<void> waitForInitialLoad() async {
    if (_initialDataLoaded) return;
    await _loadingCompleter?.future;
  }

  Stream<List<AttendanceRecord>> getUserAttendance(String id) {
    return getUserAttendanceUseCase(id);
  }

  Stream<List<Status>> getUserStatuses(String id) {
    return getUserStatusesUseCase(id);
  }
}

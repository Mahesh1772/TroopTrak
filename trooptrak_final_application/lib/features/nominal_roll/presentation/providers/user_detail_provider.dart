import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/usecases/delete_user_usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/get_user_attendance_usecase.dart';

import 'dart:async';

import '../../domain/usecases/update_user_usecase.dart';

class UserDetailProvider extends ChangeNotifier {
  final GetUserByIdUseCase getUserByIdUseCase;
  final GetUserAttendanceUseCase getUserAttendanceUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;

  UserDetailProvider(  {
    required this.getUserByIdUseCase,
    required this.getUserAttendanceUseCase,
    required this.updateUserUseCase,
    required this.deleteUserUseCase,
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

  Future<void> updateUser(User updatedUser) async {
    final result = await updateUserUseCase(updatedUser);
    result.fold(
      (failure) {
        // Handle the error, maybe show a snackbar
        print('Error updating user: $failure');
      },
      (_) {
        // Update was successful, refresh the user data
        loadUser(updatedUser.id);
      },
    );
  }
   
  Future<Either<String, void>> deleteUser(String userId) async {
    final result = await deleteUserUseCase(userId);
    return result;
  }
}

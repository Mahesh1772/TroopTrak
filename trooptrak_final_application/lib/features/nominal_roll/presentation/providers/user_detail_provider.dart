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

  UserDetailProvider({
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
  StreamSubscription? _userSubscription;

  void loadUser(String id) {
    _isLoading = true;
    _initialDataLoaded = false;
    _loadingCompleter = Completer<void>();
    notifyListeners();

    _userSubscription?.cancel();
    _userSubscription = getUserByIdUseCase(id).listen(
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
        print('Error updating user: $failure');
      },
      (_) {
        // The stream will automatically update the UI
      },
    );
  }
   
  Future<Either<String, void>> deleteUser(String userId) async {
    final result = await deleteUserUseCase(userId);
    if (result.isRight()) {
      // The user has been deleted, so we should clear the local data
      _user = null;
      _userSubscription?.cancel();
      notifyListeners();
    }
    return result;
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
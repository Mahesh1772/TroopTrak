import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/usecases/delete_user_usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/get_user_attendance_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../../detailed_view/domain/entities/attendance_record.dart' as detailed_view;
import 'dart:async';

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
  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  final _userController = StreamController<User?>.broadcast();
  Stream<User?> get userStream => _userController.stream;

  StreamSubscription? _userSubscription;

  void clearCurrentUser() {
    _user = null;
    _currentUserId = null;
    _userSubscription?.cancel();
    _userSubscription = null;
    _userController.add(null);
    _isLoading = false;
    notifyListeners();
  }

  void loadUser(String id) {
    // If we're already loading this user, don't reload
    if (_currentUserId == id && _userSubscription != null && _user != null) {
      return;
    }

    // Cancel existing subscription if any
    _userSubscription?.cancel();
    _userSubscription = null;
    
    // Reset state for new user
    _isLoading = true;
    _currentUserId = id;
    notifyListeners();

    // Start new subscription
    _userSubscription = getUserByIdUseCase(id).listen(
      (user) {
        _user = user;
        _userController.add(user);
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error loading user: $error');
        clearCurrentUser();
      },
    );
  }

  Stream<List<detailed_view.AttendanceRecord>> getUserAttendance(String userId) {
    return getUserAttendanceUseCase(userId).map((records) {
      return records.map((record) => detailed_view.AttendanceRecord(
        id: record.dateTime,
        dateTime: record.dateTime,
        isInsideCamp: record.isInsideCamp,
      )).toList();
    });
  }

  Future<void> updateUser(User updatedUser) async {
    _isLoading = true;
    notifyListeners();
    
    final result = await updateUserUseCase(updatedUser);
    result.fold(
      (failure) {
        print('Error updating user: $failure');
      },
      (_) {
        _user = updatedUser;
        _userController.add(updatedUser);
      },
    );

    _isLoading = false;
    notifyListeners();
  }
   
  Future<Either<String, void>> deleteUser(String userId) async {
    final result = await deleteUserUseCase(userId);
    if (result.isRight()) {
      if (_currentUserId == userId) {
        _user = null;
        _currentUserId = null;
        _userSubscription?.cancel();
        _userSubscription = null;
        _userController.add(null);
        notifyListeners();
      }
    }
    return result;
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _userController.close();
    super.dispose();
  }
}
import 'package:flutter/foundation.dart';
import '../../domain/entities/status.dart';
import '../../domain/usecases/get_statuses_usecase.dart';
import '../../domain/usecases/add_status_usecase.dart';
import '../../domain/usecases/update_status_usecase.dart';
import '../../domain/usecases/delete_status_usecase.dart';

class StatusProvider extends ChangeNotifier {
  final GetStatusesUseCase _getStatusesUseCase;
  final AddStatusUseCase _addStatusUseCase;
  final UpdateStatusUseCase _updateStatusUseCase;
  final DeleteStatusUseCase _deleteStatusUseCase;

  Stream<List<Status>>? _statusesStream;

  StatusProvider(
    this._getStatusesUseCase,
    this._addStatusUseCase,
    this._updateStatusUseCase,
    this._deleteStatusUseCase,
  );

  Stream<List<Status>>? get statusesStream => _statusesStream;

  void loadStatuses(String userId) {
    print('Loading statuses for user: $userId');
    _statusesStream = _getStatusesUseCase(userId);
    notifyListeners();
  }

  Stream<void> addStatus(String userId, Status status) {
    return _addStatusUseCase(userId, status);
  }

  Stream<void> updateStatus(String userId, Status status) {
    return _updateStatusUseCase(userId, status);
  }

  Stream<void> deleteStatus(String userId, String statusId) {
    return _deleteStatusUseCase(userId, statusId);
  }
}
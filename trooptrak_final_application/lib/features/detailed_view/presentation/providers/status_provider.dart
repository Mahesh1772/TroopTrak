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

  List<Status> _statuses = [];

  StatusProvider(
    this._getStatusesUseCase,
    this._addStatusUseCase,
    this._updateStatusUseCase,
    this._deleteStatusUseCase,
  );

  List<Status> get statuses => _statuses;

  Future<void> loadStatuses(String userId) async {
    _statuses = await _getStatusesUseCase(userId);
    notifyListeners();
  }

  Future<void> addStatus(String userId, Status status) async {
    await _addStatusUseCase(userId, status);
    await loadStatuses(userId);
  }

  Future<void> updateStatus(String userId, Status status) async {
    await _updateStatusUseCase(userId, status);
    await loadStatuses(userId);
  }

  Future<void> deleteStatus(String userId, String statusId) async {
    await _deleteStatusUseCase(userId, statusId);
    await loadStatuses(userId);
  }

  Status? getStatusById(String statusId) {
    return _statuses.firstWhere((status) => status.id == statusId);
  }
}
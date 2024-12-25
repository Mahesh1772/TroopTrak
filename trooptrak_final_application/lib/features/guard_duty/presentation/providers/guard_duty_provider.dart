import 'package:flutter/foundation.dart';
import '../../domain/entities/guard_duty.dart';
import '../../domain/usecases/add_guard_duty.dart';
import '../../domain/usecases/delete_guard_duty.dart';
import '../../domain/usecases/get_guard_duties.dart';
import '../../domain/usecases/update_guard_duty.dart';

class GuardDutyProvider with ChangeNotifier {
  final AddGuardDutyUseCase _addGuardDuty;
  final DeleteGuardDutyUseCase _deleteGuardDuty;
  final GetGuardDutiesUseCase _getGuardDuties;
  final UpdateGuardDutyUseCase _updateGuardDuty;

  List<GuardDuty> _duties = [];
  bool _isLoading = false;
  String? _error;

  GuardDutyProvider({
    required AddGuardDutyUseCase addGuardDuty,
    required DeleteGuardDutyUseCase deleteGuardDuty,
    required GetGuardDutiesUseCase getGuardDuties,
    required UpdateGuardDutyUseCase updateGuardDuty,
  })  : _addGuardDuty = addGuardDuty,
        _deleteGuardDuty = deleteGuardDuty,
        _getGuardDuties = getGuardDuties,
        _updateGuardDuty = updateGuardDuty;

  List<GuardDuty> get duties => _duties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDuties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _duties = await _getGuardDuties();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDuty(GuardDuty duty) async {
    try {
      await _addGuardDuty(duty);
      await loadDuties();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDuty(GuardDuty oldDuty, GuardDuty newDuty) async {
    try {
      await _updateGuardDuty(oldDuty, newDuty);
      await loadDuties();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteDuty(GuardDuty duty) async {
    try {
      await _deleteGuardDuty(duty);
      await loadDuties();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 
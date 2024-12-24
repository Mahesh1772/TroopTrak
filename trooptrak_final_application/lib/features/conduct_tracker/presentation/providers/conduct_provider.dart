import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/conduct.dart';
import '../../domain/usecases/add_conduct_usecase.dart';
import '../../domain/usecases/delete_conduct_usecase.dart';
import '../../domain/usecases/get_conducts_usecase.dart';
import '../../domain/usecases/update_conduct_usecase.dart';
import '../../domain/usecases/get_conduct_by_id_usecase.dart';

class ConductProvider extends ChangeNotifier {
  final GetConductsUseCase _getConductsUseCase;
  final AddConductUseCase _addConductUseCase;
  final UpdateConductUseCase _updateConductUseCase;
  final DeleteConductUseCase _deleteConductUseCase;
  final GetConductByIdUseCase _getConductByIdUseCase;

  ConductProvider({
    required GetConductsUseCase getConductsUseCase,
    required AddConductUseCase addConductUseCase,
    required UpdateConductUseCase updateConductUseCase,
    required DeleteConductUseCase deleteConductUseCase,
    required GetConductByIdUseCase getConductByIdUseCase,
  })  : _getConductsUseCase = getConductsUseCase,
        _addConductUseCase = addConductUseCase,
        _updateConductUseCase = updateConductUseCase,
        _deleteConductUseCase = deleteConductUseCase,
        _getConductByIdUseCase = getConductByIdUseCase;

  Stream<List<Conduct>> get conducts => _getConductsUseCase();

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> addConduct(Conduct conduct) async {
    await _addConductUseCase(conduct);
    notifyListeners();
  }

  Future<void> updateConduct(Conduct conduct) async {
    await _updateConductUseCase(conduct);
    notifyListeners();
  }

  Future<void> deleteConduct(String id) async {
    await _deleteConductUseCase(id);
    notifyListeners();
  }

  Stream<Conduct> getConductById(String id) {
    return _getConductByIdUseCase.execute(id);
  }

  List<Conduct> filterConductsByDate(List<Conduct> conducts, DateTime date) {
    return conducts.where((conduct) {
      final conductDate = DateFormat('d MMM yyyy').parse(conduct.startDate);
      return conductDate.year == date.year &&
          conductDate.month == date.month &&
          conductDate.day == date.day;
    }).toList();
  }

  List<double> getParticipationStrength(List<Conduct> conducts) {
    return conducts.map((conduct) => conduct.participants.length.toDouble()).toList();
  }
}
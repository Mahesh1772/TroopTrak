import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    try {
      final allSoldiers = await getAllSoldierIds();
      
      final nonParticipants = allSoldiers
          .where((id) => !conduct.participants.contains(id))
          .toList();

      final updatedConduct = Conduct(
        id: conduct.id,
        conductName: conduct.conductName,
        conductType: conduct.conductType,
        startDate: conduct.startDate,
        startTime: conduct.startTime,
        endTime: conduct.endTime,
        participants: conduct.participants,
        nonParticipants: nonParticipants,
        soldierReason: conduct.soldierReason,
      );

      await _addConductUseCase(updatedConduct);
      notifyListeners();
    } catch (e) {
      print('Error in addConduct: $e');
      rethrow;
    }
  }

  Future<void> updateConduct(Conduct conduct) async {
    try {
      final allSoldiers = await getAllSoldierIds();
      
      final nonParticipants = allSoldiers
          .where((id) => !conduct.participants.contains(id))
          .toList();

      final updatedConduct = Conduct(
        id: conduct.id,
        conductName: conduct.conductName,
        conductType: conduct.conductType,
        startDate: conduct.startDate,
        startTime: conduct.startTime,
        endTime: conduct.endTime,
        participants: conduct.participants,
        nonParticipants: nonParticipants,
        soldierReason: conduct.soldierReason,
      );

      await _updateConductUseCase(updatedConduct);
      notifyListeners();
    } catch (e) {
      print('Error in updateConduct: $e');
      rethrow;
    }
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

  Future<List<String>> getAllSoldierIds() async {
    final snapshot = await FirebaseFirestore.instance.collection('Users').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
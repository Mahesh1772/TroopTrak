import 'package:flutter/foundation.dart';
import '../../domain/entities/soldier.dart';
import '../../domain/usecases/get_soldiers.dart';

class SoldierProvider with ChangeNotifier {
  final GetSoldiersUseCase _getSoldiers;
  List<Soldier> _soldiers = [];
  bool _isLoading = false;
  String? _error;

  SoldierProvider({required GetSoldiersUseCase getSoldiers}) : _getSoldiers = getSoldiers {
    // Load soldiers automatically when provider is created
    loadSoldiers();
  }

  List<Soldier> get soldiers => _soldiers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSoldiers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _soldiers = await _getSoldiers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
} 
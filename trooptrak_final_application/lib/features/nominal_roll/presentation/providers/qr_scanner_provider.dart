import 'package:flutter/foundation.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/usecases/add_user_usecase.dart';
import '../../domain/usecases/scan_qr_code_usecase.dart';
import '../../domain/entities/scanned_soldier.dart';

class QRScannerProvider extends ChangeNotifier {
  final ScanQRCodeUseCase scanQRCodeUseCase;
  final AddUserUseCase addUserUseCase;

  QRScannerProvider({
    required this.scanQRCodeUseCase,
    required this.addUserUseCase,
  });

  ScannedSoldier? _scannedSoldier;
  String? _error;
  String? _lastScannedId;
  bool _isUserAdded = false;
  bool _showSuccessMessage = false;

  ScannedSoldier? get scannedSoldier => _scannedSoldier;
  String? get error => _error;
  String? get lastScannedId => _lastScannedId;
  bool get isUserAdded => _isUserAdded;
  bool get showSuccessMessage => _showSuccessMessage;

  Future<void> scanQRCode(String qrData) async {
    _lastScannedId = qrData;
    final result = await scanQRCodeUseCase(qrData);
    result.fold(
      (error) {
        _error = error;
        _scannedSoldier = null;
        _isUserAdded = false;
        _showSuccessMessage = false;
      },
      (soldier) async {
        _scannedSoldier = soldier;
        _error = null;
        final addResult = await addUserUseCase(soldier);
        addResult.fold(
          (error) {
            _error = error;
            _isUserAdded = false;
            _showSuccessMessage = false;
          },
          (_) {
            _isUserAdded = true;
            _showSuccessMessage = true;
            notifyListeners();
          },
        );
      },
    );
    notifyListeners();
  }

  void resetUserAdded() {
    _isUserAdded = false;
    _showSuccessMessage = false;
    notifyListeners();
  }

  void hideSuccessMessage() {
    _showSuccessMessage = false;
    notifyListeners();
  }
}
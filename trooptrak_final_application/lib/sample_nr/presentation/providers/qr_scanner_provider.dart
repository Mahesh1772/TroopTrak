import 'package:flutter/foundation.dart';
import 'package:trooptrak_final_application/sample_nr/domain/usecases/add_user_usecase.dart';
import '../../domain/usecases/scan_qr_code_usecase.dart';
import '../../domain/entities/scanned_soldier.dart';

// class QRScannerProvider extends ChangeNotifier {
//   final ScanQRCodeUseCase scanQRCodeUseCase;
//   final AddUserUseCase addUserUseCase;

//   QRScannerProvider({
//     required this.scanQRCodeUseCase,
//     required this.addUserUseCase,
//   });

//   ScannedSoldier? _scannedSoldier;
//   String? _error;
//   String? _lastScannedId;

//   ScannedSoldier? get scannedSoldier => _scannedSoldier;
//   String? get error => _error;
//   String? get lastScannedId => _lastScannedId;

//   Future<void> scanQRCode(String qrData) async {
//     _lastScannedId = qrData;
//     final result = await scanQRCodeUseCase(qrData);
//     result.fold(
//       (error) {
//         _error = error;
//         _scannedSoldier = null;
//       },
//       (soldier) {
//         _scannedSoldier = soldier;
//         _error = null;
//         addUserUseCase(soldier);
//       },
//     );
//     notifyListeners();
//   }
// }
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

  ScannedSoldier? get scannedSoldier => _scannedSoldier;
  String? get error => _error;
  String? get lastScannedId => _lastScannedId;
  bool get isUserAdded => _isUserAdded;

  Future<void> scanQRCode(String qrData) async {
    _lastScannedId = qrData;
    final result = await scanQRCodeUseCase(qrData);
    result.fold(
      (error) {
        _error = error;
        _scannedSoldier = null;
        _isUserAdded = false;
      },
      (soldier) async {
        _scannedSoldier = soldier;
        _error = null;
        final addResult = await addUserUseCase(soldier);
        addResult.fold(
          (error) {
            _error = error;
            _isUserAdded = false;
          },
          (_) {
            _isUserAdded = true;
          },
        );
      },
    );
    notifyListeners();
  }

  void resetUserAdded() {
    _isUserAdded = false;
    notifyListeners();
  }
}
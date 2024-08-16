// lib/sample_nr/presentation/providers/qr_scanner_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/usecases/scan_qr_code_usecase.dart';
import '../../domain/entities/scanned_soldier.dart';

class QRScannerProvider extends ChangeNotifier {
  final ScanQRCodeUseCase scanQRCodeUseCase;

  QRScannerProvider({required this.scanQRCodeUseCase});

  ScannedSoldier? _scannedSoldier;
  String? _error;

  ScannedSoldier? get scannedSoldier => _scannedSoldier;
  String? get error => _error;

  Future<void> scanQRCode(String qrData) async {
    final result = await scanQRCodeUseCase(qrData);
    result.fold(
      (error) {
        _error = error;
        _scannedSoldier = null;
      },
      (soldier) {
        _scannedSoldier = soldier;
        _error = null;
      },
    );
    notifyListeners();
  }
}
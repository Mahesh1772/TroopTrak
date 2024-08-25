// lib/sample_nr/domain/usecases/scan_qr_code_usecase.dart

import 'package:dartz/dartz.dart';
import '../repositories/qr_scanner_repository.dart';
import '../entities/scanned_soldier.dart';

class ScanQRCodeUseCase {
  final QRScannerRepository repository;

  ScanQRCodeUseCase(this.repository);

  Future<Either<String, ScannedSoldier>> call(String qrData) {
    return repository.scanQRCode(qrData);
  }
}

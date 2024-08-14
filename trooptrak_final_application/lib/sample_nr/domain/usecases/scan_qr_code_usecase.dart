import 'package:dartz/dartz.dart';
import '../repositories/qr_scanner_repository.dart';
import '../entities/scanned_soldier.dart';

class ScanQRCodeUseCase {
  final QRScannerRepository repository;

  ScanQRCodeUseCase(this.repository);

  Future<Either<String, ScannedSoldier>> call() {
    return repository.scanQRCode();
  }
}

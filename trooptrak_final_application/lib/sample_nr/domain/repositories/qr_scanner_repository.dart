// lib/sample_nr/domain/repositories/qr_scanner_repository.dart

import 'package:dartz/dartz.dart';
import '../entities/scanned_soldier.dart';

abstract class QRScannerRepository {
  Future<Either<String, ScannedSoldier>> scanQRCode(String qrData);
}
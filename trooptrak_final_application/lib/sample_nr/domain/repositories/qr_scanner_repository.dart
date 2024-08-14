import 'package:dartz/dartz.dart';
import '../entities/scanned_soldier.dart';

abstract class QRScannerRepository {
  Future<Either<String, ScannedSoldier>> scanQRCode();
}

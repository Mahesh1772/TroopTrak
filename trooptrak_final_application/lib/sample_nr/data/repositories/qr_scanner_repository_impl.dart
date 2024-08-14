// data/repositories/qr_scanner_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/entities/scanned_soldier.dart';
import '../../domain/repositories/qr_scanner_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScannerRepositoryImpl implements QRScannerRepository {
  final FirebaseFirestore _firestore;

  QRScannerRepositoryImpl(this._firestore);

  @override
  Future<Either<String, ScannedSoldier>> scanQRCode() async {
    try {
      final controller = MobileScannerController();
      String? scannedData;

      // Wait for the first barcode to be scanned
      await for (final capture in controller.barcodes) {
        if (capture.barcodes.isNotEmpty) {
          scannedData = capture.barcodes.first.rawValue;
          break;
        }
      }

      if (scannedData != null) {
        final soldierData = await _firestore.collection('Users').doc(scannedData).get();

        if (soldierData.exists) {
          final data = soldierData.data() as Map<String, dynamic>;
          return Right(ScannedSoldier(
            id: soldierData.id,
            name: data['name'] ?? '',
            rank: data['rank'] ?? '',
            company: data['company'] ?? '',
            appointment: data['appointment'] ?? '',
            bloodGroup: data['bloodgroup'] ?? '',
            dob: data['dob'] ?? '',
            enlistment: data['enlistment'] ?? '',
            platoon: data['platoon'] ?? '',
            section: data['section'] ?? '',
            rationType: data['rationType'] ?? '',
          ));
        } else {
          return const Left('Soldier not found');
        }
      } else {
        return const Left('No QR code scanned');
      }
    } catch (e) {
      return Left('Error scanning QR code: $e');
    }
  }
}
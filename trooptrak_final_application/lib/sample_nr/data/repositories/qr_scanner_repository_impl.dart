// lib/sample_nr/data/repositories/qr_scanner_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/scanned_soldier.dart';
import '../../domain/repositories/qr_scanner_repository.dart';

class QRScannerRepositoryImpl implements QRScannerRepository {
  final FirebaseFirestore _firestore;

  QRScannerRepositoryImpl(this._firestore);

  @override
  Future<Either<String, ScannedSoldier>> scanQRCode(String qrData) async {
    try {
      final soldierData = await _firestore.collection('Men').doc(qrData).get();

      if (soldierData.exists) {
        final data = soldierData.data() as Map<String, dynamic>;
        return Right(ScannedSoldier(
          id: soldierData.id,
          name: data['name'] ?? '',
          rank: data['rank'] ?? '',
          company: data['company'] ?? '',
          appointment: data['appointment'] ?? '',
          bloodgroup: data['bloodgroup'] ?? '',
          currentAttendance: data['currentAttendance'] ?? '',
          dob: data['dob'] ?? '',
          enlistment: data['enlistment'] ?? '',
          platoon: data['platoon'] ?? '',
          section: data['section'] ?? '',
          rationType: data['rationType'] ?? '',
          points: data['points'] ?? '',
        ));
      } else {
        return const Left('Soldier not found');
      }
    } catch (e) {
      return Left('Error scanning QR code: $e');
    }
  }
}
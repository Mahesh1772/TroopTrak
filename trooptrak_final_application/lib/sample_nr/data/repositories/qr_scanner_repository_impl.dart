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
    final QuerySnapshot querySnapshot = await _firestore.collection('Men').get();
    
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['QRid'] == qrData) {
        return Right(ScannedSoldier(
          id: doc.id,
          name: data['name'] ?? '',
          rank: data['rank'] ?? '',
          company: data['company'] ?? '',
          appointment: data['appointment'] ?? '',
          bloodgroup: data['bloodgroup'] ?? '',
          currentAttendance: 'Inside Camp',
          dob: data['dob'] ?? '',
          enlistment: data['enlistment'] ?? '',
          ord: data['ord'] ?? '',
          platoon: data['platoon'] ?? '',
          section: data['section'] ?? '',
          rationType: data['rationType'] ?? '',
          points: data['points'] ?? ''
        ));
      }
    }
    return const Left('QRid not found');
    } catch (e) {
      return Left('Error scanning QR code: $e');
    }
  }
}

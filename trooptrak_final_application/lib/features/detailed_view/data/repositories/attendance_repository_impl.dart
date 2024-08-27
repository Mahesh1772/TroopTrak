import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final FirebaseFirestore _firestore;

  AttendanceRepositoryImpl(this._firestore);

  @override
  Stream<List<AttendanceRecord>> getUserAttendance(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('Attendance')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromJson(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> updateAttendance(String userId, AttendanceRecord record) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('Attendance')
        .doc(record.id)
        .update((record as AttendanceModel).toJson());
  }

  @override
  Future<void> deleteAttendance(String userId, String recordId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('Attendance')
        .doc(recordId)
        .delete();
  }
}
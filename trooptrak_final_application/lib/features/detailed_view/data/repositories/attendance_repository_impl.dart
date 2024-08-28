import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
        .orderBy('date&time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromJson(doc.id, doc.data()))
            .toList());
  }

  @override
  Stream<void> updateAttendance(String userId, AttendanceRecord record) {
    return Stream.fromFuture(
      _firestore
          .collection('Users')
          .doc(userId)
          .collection('Attendance')
          .doc(record.id)
          .update({
        'date&time': record.dateTime,
        'isInsideCamp': record.isInsideCamp,
      })
    );
  }

  @override
  Stream<void> deleteAttendance(String userId, String recordId) {
    return Stream.fromFuture(
      _firestore
          .collection('Users')
          .doc(userId)
          .collection('Attendance')
          .doc(recordId)
          .delete()
    );
  }

  @override
  Stream<void> updateUserAttendance(String userId, bool isInsideCamp) {
    return Stream.fromFuture(_updateUserAttendanceImpl(userId, isInsideCamp));
  }

  Future<void> _updateUserAttendanceImpl(String userId, bool isInsideCamp) async {
    await _firestore.collection('Users').doc(userId).update({
      'currentAttendance': isInsideCamp ? 'Inside Camp' : 'Outside',
    });

    String docId = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Attendance')
        .doc(docId)
        .set({
      'date&time': DateFormat('E d MMM yyyy HH:mm:ss').format(DateTime.now()),
      'isInsideCamp': isInsideCamp,
    });
  }
}
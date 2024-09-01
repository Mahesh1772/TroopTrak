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
  Stream<void> updateAttendance(String userId, AttendanceRecord record) async* {
    final batch = _firestore.batch();

    // Update the attendance record
    final attendanceRef = _firestore
        .collection('Users')
        .doc(userId)
        .collection('Attendance')
        .doc(record.id);
    batch.update(attendanceRef, {
      'date&time': record.dateTime,
      'isInsideCamp': record.isInsideCamp,
    });

    // Check if this is the latest attendance record
    final latestAttendance = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Attendance')
        .orderBy('date&time', descending: true)
        .limit(1)
        .get();

    if (latestAttendance.docs.isNotEmpty && latestAttendance.docs.first.id == record.id) {
      // If it's the latest record, update the user's currentAttendance
      final userRef = _firestore.collection('Users').doc(userId);
      batch.update(userRef, {
        'currentAttendance': record.isInsideCamp ? 'Inside Camp' : 'Outside',
      });
    }

    yield* Stream.fromFuture(batch.commit());
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
  Stream<void> updateUserAttendance(String userId, bool isInsideCamp) async* {
    final batch = _firestore.batch();

    // Create a new attendance record
    String docId = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final attendanceRef = _firestore
        .collection('Users')
        .doc(userId)
        .collection('Attendance')
        .doc(docId);
    
    batch.set(attendanceRef, {
      'date&time': DateFormat('E d MMM yyyy HH:mm:ss').format(DateTime.now()),
      'isInsideCamp': isInsideCamp,
    });

    // Update the user's currentAttendance
    final userRef = _firestore.collection('Users').doc(userId);
    batch.update(userRef, {
      'currentAttendance': isInsideCamp ? 'Inside Camp' : 'Outside',
    });

    yield* Stream.fromFuture(batch.commit());
  }

  @override
  Stream<void> updateAttendanceAndUserStatus(String userId, AttendanceRecord record, bool isInsideCamp) async* {
    final batch = _firestore.batch();

    // Update the attendance record
    final attendanceRef = _firestore
        .collection('Users')
        .doc(userId)
        .collection('Attendance')
        .doc(record.id);
    batch.update(attendanceRef, {
      'date&time': record.dateTime,
      'isInsideCamp': record.isInsideCamp,
    });

    // Check if this is the latest attendance record
    final latestAttendance = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Attendance')
        .orderBy('date&time', descending: true)
        .limit(1)
        .get();

    if (latestAttendance.docs.isNotEmpty && latestAttendance.docs.first.id == record.id) {
      // If it's the latest record, update the user's currentAttendance
      final userRef = _firestore.collection('Users').doc(userId);
      batch.update(userRef, {
        'currentAttendance': isInsideCamp ? 'Inside Camp' : 'Outside',
      });
    }

    yield* Stream.fromFuture(batch.commit());
  }
}
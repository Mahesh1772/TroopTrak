import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/attendance_record.dart';
import '../models/attendance_model.dart';

class AttendanceRemoteDataSource {
  AttendanceRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String soldierId) =>
      _db.collection(Collections.users).doc(soldierId);

  CollectionReference<Map<String, dynamic>> _records(String soldierId) =>
      _user(soldierId).collection(Collections.attendance);

  Stream<List<AttendanceRecord>> watchForSoldier(String soldierId) =>
      _records(soldierId).snapshots().map((snap) => [
            for (final d in snap.docs)
              AttendanceModel.fromMap(soldierId, d.id, d.data())
          ]);

  Stream<List<AttendanceRecord>> watchAll() =>
      _db.collectionGroup(Collections.attendance).snapshots().map((snap) => [
            for (final d in snap.docs)
              if (d.reference.parent.parent != null)
                AttendanceModel.fromMap(
                    d.reference.parent.parent!.id, d.id, d.data())
          ]);

  Future<void> bookInOut(String soldierId, bool isInsideCamp, DateTime at) {
    final record = AttendanceRecord(
      id: attendanceDocId(at),
      soldierId: soldierId,
      isInsideCamp: isInsideCamp,
      timestamp: at,
    );
    final batch = _db.batch()
      ..set(_records(soldierId).doc(record.id), AttendanceModel.toMap(record))
      ..set(
        _user(soldierId),
        {
          UserFields.currentAttendance: isInsideCamp
              ? AttendanceValues.insideCamp
              : AttendanceValues.outside,
        },
        SetOptions(merge: true),
      );
    return batch.commit();
  }

  Future<void> update(AttendanceRecord record) =>
      _records(record.soldierId).doc(record.id).update({
        AttendanceFields.dateTime: attendanceDisplay(record.timestamp),
      });

  Future<void> delete(AttendanceRecord record) =>
      _records(record.soldierId).doc(record.id).delete();
}

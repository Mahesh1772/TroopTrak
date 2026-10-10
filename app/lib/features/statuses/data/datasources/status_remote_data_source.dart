import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/status.dart';
import '../models/status_model.dart';

class StatusRemoteDataSource {
  StatusRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String soldierId) =>
      _db.collection(Collections.users).doc(soldierId);

  CollectionReference<Map<String, dynamic>> _statuses(String soldierId) =>
      _user(soldierId).collection(Collections.statuses);

  CollectionReference<Map<String, dynamic>> _attendance(String soldierId) =>
      _user(soldierId).collection(Collections.attendance);

  Stream<List<Status>> watchForSoldier(String soldierId) =>
      _statuses(soldierId).snapshots().map((snap) => [
            for (final d in snap.docs)
              StatusModel.fromMap(soldierId, d.id, d.data())
          ]);

  Stream<List<Status>> watchAll() =>
      _db.collectionGroup(Collections.statuses).snapshots().map(_fromGroup);

  Future<List<Status>> getAll() async =>
      _fromGroup(await _db.collectionGroup(Collections.statuses).get());

  List<Status> _fromGroup(QuerySnapshot<Map<String, dynamic>> snap) => [
        for (final d in snap.docs)
          if (d.reference.parent.parent != null)
            StatusModel.fromMap(d.reference.parent.parent!.id, d.id, d.data())
      ];

  Future<void> add(Status status) async {
    final batch = _db.batch()
      ..set(_statuses(status.soldierId).doc(), StatusModel.toMap(status));
    _writeLinked(batch, status);
    await batch.commit();
  }

  Future<void> update(Status previous, Status updated) async {
    final batch = _db.batch()
      ..update(
        _statuses(previous.soldierId).doc(previous.id),
        StatusModel.toMap(updated),
      );
    final keep = {
      for (final entry in updated.linkedAttendance) attendanceDocId(entry.at)
    };
    _deleteLinked(batch, previous, except: keep);
    _writeLinked(batch, updated);
    await batch.commit();
  }

  Future<void> delete(Status status) async {
    final batch = _db.batch()
      ..delete(_statuses(status.soldierId).doc(status.id));
    _deleteLinked(batch, status);
    await batch.commit();
  }

  void _writeLinked(WriteBatch batch, Status status) {
    for (final entry in status.linkedAttendance) {
      batch.set(_attendance(status.soldierId).doc(attendanceDocId(entry.at)), {
        AttendanceFields.isInsideCamp: entry.isInsideCamp,
        AttendanceFields.dateTime: attendanceDisplay(entry.at),
      });
    }
  }

  void _deleteLinked(
    WriteBatch batch,
    Status status, {
    Set<String> except = const {},
  }) {
    for (final id in StatusModel.linkedIds(status)) {
      if (!except.contains(id)) {
        batch.delete(_attendance(status.soldierId).doc(id));
      }
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/data/firestore_helpers.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/soldier.dart';
import '../models/soldier_model.dart';

class SoldierRemoteDataSource {
  SoldierRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(Collections.users);

  Stream<List<Soldier>> watchAll() => _users.snapshots().map((snap) =>
      [for (final d in snap.docs) SoldierModel.fromMap(d.id, d.data())]);

  Stream<Soldier> watchById(String id) => _users.doc(id).snapshots().map((doc) {
        final data = doc.data();
        if (!doc.exists || data == null) {
          throw NotFoundException('Soldier $id was not found.');
        }
        return SoldierModel.fromMap(doc.id, data);
      });

  Future<List<Soldier>> getAll() async {
    final snap = await _users.get();
    return [for (final d in snap.docs) SoldierModel.fromMap(d.id, d.data())];
  }

  Future<bool> exists(String id) async => (await _users.doc(id).get()).exists;

  Future<void> add(Soldier soldier, DateTime createdAt) async {
    final ref = _users.doc(soldier.id);
    final batch = _db.batch()
      ..set(ref, SoldierModel.toCreateMap(soldier))
      ..set(
          ref
              .collection(Collections.attendance)
              .doc(attendanceDocId(createdAt)),
          {
            AttendanceFields.isInsideCamp: true,
            AttendanceFields.dateTime: attendanceDisplay(createdAt),
          });
    await batch.commit();
  }

  Future<void> update(Soldier soldier) =>
      _users.doc(soldier.id).update(SoldierModel.toProfileMap(soldier));

  Future<void> delete(String id) async {
    final ref = _users.doc(id);
    final statuses = await ref.collection(Collections.statuses).get();
    final attendance = await ref.collection(Collections.attendance).get();
    await deleteInChunks(_db, [
      for (final d in statuses.docs) d.reference,
      for (final d in attendance.docs) d.reference,
      ref,
    ]);
  }

  Future<void> setPoints(String id, double points) =>
      _users.doc(id).update({UserFields.points: points});

  Future<void> adjustPoints(String id, double delta) =>
      _db.runTransaction((tx) async {
        final ref = _users.doc(id);
        final snap = await tx.get(ref);
        if (!snap.exists) throw NotFoundException('Soldier $id was not found.');
        final current = readDouble(snap.data()?[UserFields.points]);
        tx.update(
            ref, {UserFields.points: Soldier.pointsAfter(current, delta)});
      });
}

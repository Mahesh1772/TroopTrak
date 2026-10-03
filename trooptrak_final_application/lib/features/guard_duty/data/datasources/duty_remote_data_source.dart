import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/data/firestore_helpers.dart';
import '../../domain/entities/duty.dart';
import '../../domain/services/duty_points.dart';
import '../models/duty_model.dart';

class DutyRemoteDataSource {
  DutyRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _duties =>
      _db.collection(Collections.duties);

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(Collections.users);

  Stream<List<Duty>> watchAll() => _duties.snapshots().map(
      (snap) => [for (final d in snap.docs) DutyModel.fromMap(d.id, d.data())]);

  Future<void> add(Duty duty, Map<String, PointsChange> changes) {
    final ref = _duties.doc();
    return _write(changes, (tx) => tx.set(ref, DutyModel.toMap(duty)));
  }

  Future<void> update(Duty duty, Map<String, PointsChange> changes) => _write(
      changes, (tx) => tx.set(_duties.doc(duty.id), DutyModel.toMap(duty)));

  Future<void> delete(Duty duty, Map<String, PointsChange> changes) =>
      _write(changes, (tx) => tx.delete(_duties.doc(duty.id)));

  /// K5: the duty and every participant's points change atomically. Users
  /// docs are keyed by name, as in the source; missing ones are skipped.
  Future<void> _write(
    Map<String, PointsChange> changes,
    void Function(Transaction tx) writeDuty,
  ) =>
      _db.runTransaction((tx) async {
        final current = <DocumentReference<Map<String, dynamic>>,
            (DocumentSnapshot<Map<String, dynamic>>, PointsChange)>{};
        for (final entry in changes.entries) {
          final ref = _users.doc(entry.key);
          current[ref] = (await tx.get(ref), entry.value);
        }
        writeDuty(tx);
        for (final MapEntry(key: ref, value: (snap, change))
            in current.entries) {
          if (!snap.exists) continue;
          final points = readDouble(snap.data()?[UserFields.points]);
          tx.update(ref, {UserFields.points: change.applyTo(points)});
        }
      });
}

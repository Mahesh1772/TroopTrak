import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/conduct.dart';
import '../models/conduct_model.dart';

class ConductRemoteDataSource {
  ConductRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _conducts =>
      _db.collection(Collections.conducts);

  List<Conduct> _list(QuerySnapshot<Map<String, dynamic>> snap) =>
      [for (final d in snap.docs) ConductModel.fromMap(d.id, d.data())];

  Stream<List<Conduct>> watchAll() => _conducts.snapshots().map(_list);

  Stream<List<Conduct>> watchOnDay(DateTime day) => _conducts
      .where(ConductFields.startDate, isEqualTo: formatDay(day))
      .snapshots()
      .map(_list);

  Stream<Conduct> watchById(String id) =>
      _conducts.doc(id).snapshots().map((doc) {
        final data = doc.data();
        if (!doc.exists || data == null) {
          throw NotFoundException('Conduct $id was not found.');
        }
        return ConductModel.fromMap(doc.id, data);
      });

  Future<void> add(Conduct conduct) =>
      _conducts.add(ConductModel.toMap(conduct));

  Future<void> update(Conduct conduct) =>
      _conducts.doc(conduct.id).update(ConductModel.toMap(conduct));

  Future<void> delete(String id) => _conducts.doc(id).delete();
}

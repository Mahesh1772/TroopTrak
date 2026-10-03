import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_keys.dart';

class MenRemoteDataSource {
  MenRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _men =>
      _db.collection(Collections.men);

  Future<bool> exists(String uid) async => (await _men.doc(uid).get()).exists;
}

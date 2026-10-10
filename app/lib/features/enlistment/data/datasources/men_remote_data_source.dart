import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/entities/soldier_registration.dart';
import '../models/men_model.dart';

class MenRemoteDataSource {
  MenRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _men =>
      _db.collection(Collections.men);

  Future<bool> exists(String uid) async => (await _men.doc(uid).get()).exists;

  Future<SoldierRegistration> get(String uid) async {
    final doc = await _men.doc(uid).get();
    final data = doc.data();
    if (!doc.exists || data == null) {
      throw NotFoundException('No registration found for $uid.');
    }
    return MenModel.fromMap(doc.id, data);
  }

  Stream<SoldierRegistration> watch(String uid) =>
      _men.doc(uid).snapshots().map((doc) {
        final data = doc.data();
        if (!doc.exists || data == null) {
          throw NotFoundException('No registration found for $uid.');
        }
        return MenModel.fromMap(doc.id, data);
      });

  Future<void> updateProfile(String uid, Soldier profile) =>
      _men.doc(uid).update(MenModel.toProfileMap(profile));

  Future<void> save(String uid, Soldier profile) =>
      _men.doc(uid).set(MenModel.toCreateMap(profile));

  Future<void> setQrId(String uid, String? qrId) =>
      _men.doc(uid).set({MenFields.qrId: qrId}, SetOptions(merge: true));

  Future<SoldierRegistration?> findByQrId(String qrId) async {
    final snap =
        await _men.where(MenFields.qrId, isEqualTo: qrId).limit(1).get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.single;
    return MenModel.fromMap(doc.id, doc.data());
  }
}

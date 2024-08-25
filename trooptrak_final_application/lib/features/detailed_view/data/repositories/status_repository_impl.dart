import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/status.dart';
import '../../domain/repositories/status_repository.dart';
import '../models/status_model.dart';

class StatusRepositoryImpl implements StatusRepository {
  final FirebaseFirestore _firestore;

  StatusRepositoryImpl(this._firestore);
      // : _firestore = firestore ?? FirebaseFirestore.instance;

  
  @override
  Future<List<Status>> getStatuses(String userId) async {
    final snapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Statuses')
        .get();

    return snapshot.docs
        .map((doc) => StatusModel.fromJson(doc.data()..addAll({'ID': doc.id})))
        .toList();
  }

  @override
  Future<void> addStatus(String userId, Status status) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Statuses')
        .add((status as StatusModel).toJson());
  }

  @override
  Future<void> updateStatus(String userId, Status status) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Statuses')
        .doc(status.id)
        .update((status as StatusModel).toJson());
  }

  @override
  Future<void> deleteStatus(String userId, String statusId) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Statuses')
        .doc(statusId)
        .delete();
  }
}
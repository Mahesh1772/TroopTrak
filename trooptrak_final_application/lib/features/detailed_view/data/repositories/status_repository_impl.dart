import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/status.dart';
import '../../domain/repositories/status_repository.dart';
import '../models/status_model.dart';

class StatusRepositoryImpl implements StatusRepository {
  final FirebaseFirestore _firestore;

  StatusRepositoryImpl(this._firestore);

  @override
  Stream<List<Status>> getStatuses(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('Statuses')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Status(
          id: doc.id,
          statusName: data['statusName'] ?? '',
          statusType: data['statusType'] ?? '',
          startDate: data['startDate'] ?? '',
          endDate: data['endDate'] ?? '',
          startId: data['start_id'] ?? '',
          endId: data['end_id'] ?? '',
        );
      }).toList();
    });
  }

  @override
  Stream<void> addStatus(String userId, Status status) {
    final statusModel = StatusModel(
      id: status.id,
      statusType: status.statusType,
      statusName: status.statusName,
      startDate: status.startDate,
      endDate: status.endDate,
      startId: status.startId,
      endId: status.endId,
    );
    return Stream.fromFuture(_firestore
        .collection('Users')
        .doc(userId)
        .collection('Statuses')
        .add(statusModel.toJson()));
  }

  @override
  Stream<void> updateStatus(String userId, Status status) {
    final statusModel = StatusModel(
      id: status.id,
      statusType: status.statusType,
      statusName: status.statusName,
      startDate: status.startDate,
      endDate: status.endDate,
      startId: status.startId,
      endId: status.endId,
    );
    return Stream.fromFuture(_firestore
        .collection('Users')
        .doc(userId)
        .collection('Statuses')
        .doc(status.id)
        .update(statusModel.toJson()));
  }

  @override
  Stream<void> deleteStatus(String userId, String statusId) {
    return Stream.fromFuture(_firestore
        .collection('Users')
        .doc(userId)
        .collection('Statuses')
        .doc(statusId)
        .delete());
  }
}

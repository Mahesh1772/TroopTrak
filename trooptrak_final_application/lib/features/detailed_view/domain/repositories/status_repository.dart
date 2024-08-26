import '../entities/status.dart';

abstract class StatusRepository {
  Stream<List<Status>> getStatuses(String userId);
  Stream<void> addStatus(String userId, Status status);
  Stream<void> updateStatus(String userId, Status status);
  Stream<void> deleteStatus(String userId, String statusId);
}

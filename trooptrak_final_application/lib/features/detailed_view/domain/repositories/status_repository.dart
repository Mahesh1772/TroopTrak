import '../entities/status.dart';

abstract class StatusRepository {
  Future<List<Status>> getStatuses(String userId);
  Future<void> addStatus(String userId, Status status);
  Future<void> updateStatus(String userId, Status status);
  Future<void> deleteStatus(String userId, String statusId);
}
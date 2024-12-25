import 'package:trooptrak_final_application/features/guard_duty/domain/entities/guard_duty.dart';

abstract class GuardDutyRepository {
  Future<List<GuardDuty>> getGuardDuties();
  Future<void> addGuardDuty(GuardDuty duty);
  Future<void> updateGuardDuty(GuardDuty duty);
  Future<void> deleteGuardDuty(String dutyId);
  Future<void> updateUserPoints(String userId, int points);
} 
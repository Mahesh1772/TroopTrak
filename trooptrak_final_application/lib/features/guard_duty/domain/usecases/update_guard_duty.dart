import '../entities/guard_duty.dart';
import '../repositories/guard_duty_repository.dart';

class UpdateGuardDutyUseCase {
  final GuardDutyRepository repository;

  UpdateGuardDutyUseCase(this.repository);

  Future<void> call(GuardDuty oldDuty, GuardDuty newDuty) async {
    // First remove old points
    for (final participant in oldDuty.participants.keys) {
      await repository.updateUserPoints(participant, -oldDuty.points);
    }

    // Update the duty
    await repository.updateGuardDuty(newDuty);

    // Add new points
    for (final participant in newDuty.participants.keys) {
      await repository.updateUserPoints(participant, newDuty.points);
    }
  }
} 
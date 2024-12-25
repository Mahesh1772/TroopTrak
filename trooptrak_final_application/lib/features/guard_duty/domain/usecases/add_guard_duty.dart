import '../entities/guard_duty.dart';
import '../repositories/guard_duty_repository.dart';

class AddGuardDutyUseCase {
  final GuardDutyRepository repository;

  AddGuardDutyUseCase(this.repository);

  Future<void> call(GuardDuty duty) async {
    await repository.addGuardDuty(duty);
    
    // Update points for all participants
    for (final participant in duty.participants.keys) {
      await repository.updateUserPoints(participant, duty.points);
    }
  }
} 
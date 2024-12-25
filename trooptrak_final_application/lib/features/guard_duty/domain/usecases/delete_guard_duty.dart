import 'package:trooptrak_final_application/features/guard_duty/domain/entities/guard_duty.dart';

import '../repositories/guard_duty_repository.dart';

class DeleteGuardDutyUseCase {
  final GuardDutyRepository repository;

  DeleteGuardDutyUseCase(this.repository);

  Future<void> call(GuardDuty duty) async {
    await repository.deleteGuardDuty(duty.id);
    
    // Remove points from participants
    for (final participant in duty.participants.keys) {
      await repository.updateUserPoints(participant, -duty.points);
    }
  }
} 
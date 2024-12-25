import '../entities/guard_duty.dart';
import '../repositories/guard_duty_repository.dart';

class GetGuardDutiesUseCase {
  final GuardDutyRepository repository;

  GetGuardDutiesUseCase(this.repository);

  Future<List<GuardDuty>> call() async {
    return await repository.getGuardDuties();
  }
} 
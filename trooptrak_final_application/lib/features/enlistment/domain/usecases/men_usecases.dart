import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/soldier_registration.dart';
import '../repositories/men_repository.dart';

class SoldierProfileExists implements UseCase<bool, String> {
  const SoldierProfileExists(this._repository);

  final MenRepository _repository;

  @override
  Result<bool> call(String uid) => _repository.exists(uid);
}

/// R15: the commander's scan; `Right(null)` when no soldier shows that code.
class FindRegistrationByQr implements UseCase<SoldierRegistration?, String> {
  const FindRegistrationByQr(this._repository);

  final MenRepository _repository;

  @override
  Result<SoldierRegistration?> call(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return const Right(null);
    return _repository.findByQrId(trimmed);
  }
}

import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../../../../core/services/id_generator.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../soldiers/domain/entities/soldier.dart';
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

/// R15: puts a fresh one-time code on `Men/{uid}.QRid` and returns it.
class PublishEnlistmentQr implements UseCase<String, String> {
  const PublishEnlistmentQr(this._repository, this._ids);

  final MenRepository _repository;
  final IdGenerator _ids;

  @override
  Result<String> call(String uid) async {
    final code = _ids.next();
    final result = await _repository.setQrId(uid, code);
    return result.map((_) => code);
  }
}

/// R15: withdraws the soldier's code so it can no longer be scanned.
class ClearEnlistmentQr implements UseCase<Unit, String> {
  const ClearEnlistmentQr(this._repository);

  final MenRepository _repository;

  @override
  Result<Unit> call(String uid) => _repository.setQrId(uid, null);
}

/// The soldier's own profile from `Men/{uid}`; its id is the linked Users id.
class WatchOwnRegistration implements StreamUseCase<Soldier, String> {
  const WatchOwnRegistration(this._repository);

  final MenRepository _repository;

  @override
  ResultStream<Soldier> call(String uid) =>
      _repository.watch(uid).map((r) => r.map((reg) => reg.profile));
}

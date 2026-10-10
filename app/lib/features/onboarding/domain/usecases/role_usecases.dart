import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_role.dart';
import '../repositories/role_repository.dart';

class GetRole implements UseCase<AppRole?, NoParams> {
  const GetRole(this._repository);

  final RoleRepository _repository;

  @override
  Result<AppRole?> call(NoParams params) => _repository.getRole();
}

class SetRole implements UseCase<Unit, AppRole> {
  const SetRole(this._repository);

  final RoleRepository _repository;

  @override
  Result<Unit> call(AppRole role) => _repository.setRole(role);
}

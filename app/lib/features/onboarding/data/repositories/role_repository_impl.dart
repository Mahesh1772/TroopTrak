import 'package:dartz/dartz.dart';

import '../../../../core/data/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/preferences_service.dart';
import '../../domain/entities/app_role.dart';
import '../../domain/repositories/role_repository.dart';

class RoleRepositoryImpl implements RoleRepository {
  RoleRepositoryImpl(this._preferences);

  final PreferencesService _preferences;

  @override
  Result<AppRole?> getRole() =>
      guard(() async => AppRole.fromValue(_preferences.onBoard));

  @override
  Result<Unit> setRole(AppRole role) => guard(() async {
        await _preferences.setOnBoard(role.value);
        return unit;
      });
}

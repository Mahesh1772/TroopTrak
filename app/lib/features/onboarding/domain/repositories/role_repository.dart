import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../entities/app_role.dart';

abstract interface class RoleRepository {
  Result<AppRole?> getRole();

  Result<Unit> setRole(AppRole role);
}

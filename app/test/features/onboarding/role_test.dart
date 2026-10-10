import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/services/preferences_service.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/onboarding/data/repositories/role_repository_impl.dart';
import 'package:trooptrak_final_application/features/onboarding/domain/entities/app_role.dart';
import 'package:trooptrak_final_application/features/onboarding/domain/usecases/role_usecases.dart';

void main() {
  Future<RoleRepositoryImpl> repoWith(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    return RoleRepositoryImpl(await PreferencesService.create());
  }

  test('AppRole maps the onBoard values 1 and 2 (R18)', () {
    expect(AppRole.fromValue(1), AppRole.soldier);
    expect(AppRole.fromValue(2), AppRole.commander);
    expect(AppRole.fromValue(null), isNull);
    expect(AppRole.fromValue(3), isNull);
    expect(AppRole.soldier.value, 1);
    expect(AppRole.commander.value, 2);
  });

  test('no stored value means no role', () async {
    final repo = await repoWith({});
    expect(await GetRole(repo)(const NoParams()),
        const Right<Failure, AppRole?>(null));
  });

  test('stored 1 and 2 read as soldier and commander', () async {
    expect(await GetRole(await repoWith({'onBoard': 1}))(const NoParams()),
        const Right<Failure, AppRole?>(AppRole.soldier));
    expect(await GetRole(await repoWith({'onBoard': 2}))(const NoParams()),
        const Right<Failure, AppRole?>(AppRole.commander));
  });

  test('setRole persists the onBoard value', () async {
    final repo = await repoWith({});
    expect(await SetRole(repo)(AppRole.commander),
        const Right<Failure, Unit>(unit));
    expect((await SharedPreferences.getInstance()).getInt('onBoard'), 2);
    expect(await GetRole(repo)(const NoParams()),
        const Right<Failure, AppRole?>(AppRole.commander));
  });
}

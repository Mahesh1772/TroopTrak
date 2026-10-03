import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/onboarding/data/repositories/role_repository_impl.dart';
import '../../features/onboarding/domain/usecases/role_usecases.dart';
import '../services/clock.dart';
import '../services/preferences_service.dart';
import '../theme/theme_manager.dart';

class AppDependencies {
  AppDependencies({
    required this.preferences,
    this.clock = const SystemClock(),
  });

  final PreferencesService preferences;
  final Clock clock;

  static Future<AppDependencies> create() async =>
      AppDependencies(preferences: await PreferencesService.create());

  List<SingleChildWidget> get providers {
    final roles = RoleRepositoryImpl(preferences);
    return [
      Provider<Clock>.value(value: clock),
      Provider<PreferencesService>.value(value: preferences),
      ChangeNotifierProvider<ThemeManager>(create: (_) => ThemeManager()),
      Provider(create: (_) => GetRole(roles)),
      Provider(create: (_) => SetRole(roles)),
    ];
  }
}

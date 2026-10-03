import 'package:flutter/material.dart';

import '../../features/auth/presentation/auth_routes.dart';
import '../../features/conducts/presentation/conducts_routes.dart';
import '../../features/enlistment/presentation/enlistment_routes.dart';
import '../../features/guard_duty/presentation/guard_duty_routes.dart';
import '../../features/nominal_roll/presentation/nominal_roll_routes.dart';
import '../../features/onboarding/presentation/onboarding_routes.dart';
import '../../features/soldier_profile/presentation/soldier_profile_routes.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/feedback_views.dart';
import 'app_routes.dart';
import 'commander_routes.dart';
import 'route_builder.dart';
import 'soldier_routes.dart';

abstract final class AppRouter {
  static final Map<String, RouteWidgetBuilder> routes = {
    ...onboardingRoutes,
    ...authRoutes(commanderHome: (_) => const CommanderHome()),
    ...soldierProfileRoutes,
    AppRoutes.commanderProfile: commanderProfile,
    ...enlistmentRoutes,
    ...soldierFormRoutes,
    ...conductRoutes,
    ...dutyRoutes,
    AppRoutes.soldierHome: (_, __) => const SoldierHome(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name] ?? (_, __) => const _UnknownRoute();
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) => builder(context, settings.arguments),
    );
  }
}

class _UnknownRoute extends StatelessWidget {
  const _UnknownRoute();

  @override
  Widget build(BuildContext context) => const AppScaffold(
        title: 'TroopTrak',
        body: ErrorView(message: 'Page not found.'),
      );
}

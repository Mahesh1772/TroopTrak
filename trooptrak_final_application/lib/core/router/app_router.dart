import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/auth_routes.dart';
import '../../features/enlistment/presentation/enlistment_routes.dart';
import '../../features/nominal_roll/presentation/nominal_roll_routes.dart';
import '../../features/onboarding/presentation/onboarding_routes.dart';
import '../../features/shell/presentation/pages/commander_shell.dart';
import '../../features/soldier_profile/presentation/soldier_profile_routes.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/feedback_views.dart';
import 'app_routes.dart';
import 'route_builder.dart';

abstract final class AppRouter {
  static final Map<String, RouteWidgetBuilder> routes = {
    ...onboardingRoutes,
    ...authRoutes(commanderHome: (_) => const _CommanderHome()),
    ...soldierProfileRoutes,
    AppRoutes.commanderProfile: (_, __) =>
        const _Placeholder('My profile', title: 'Profile'),
    AppRoutes.editSoldier: (_, __) =>
        const _Placeholder('Edit soldier', title: 'Edit soldier'),
    ...enlistmentRoutes,
    AppRoutes.addSoldier: (_, __) =>
        const _Placeholder('Add soldier', title: 'Add soldier'),
    AppRoutes.soldierHome: (_, __) => const _Placeholder('Soldier app'),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name] ?? (_, __) => const _UnknownRoute();
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) => builder(context, settings.arguments),
    );
  }
}

class _CommanderHome extends StatelessWidget {
  const _CommanderHome();

  @override
  Widget build(BuildContext context) {
    final me = context.read<WatchAuthState>().current?.displayName;
    return CommanderShell(
      home: (_) => const EmptyState(message: 'Dashboard', image: null),
      nominalRoll: (context) => nominalRollTab(context, currentUserId: me),
      conductTracker: (_) =>
          const EmptyState(message: 'Conduct Tracker', image: null),
      guardDuty: (_) => const EmptyState(message: 'Guard Duty', image: null),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label, {this.title});

  final String label;
  final String? title;

  @override
  Widget build(BuildContext context) =>
      AppScaffold(title: title, body: EmptyState(message: label, image: null));
}

class _UnknownRoute extends StatelessWidget {
  const _UnknownRoute();

  @override
  Widget build(BuildContext context) => const AppScaffold(
        title: 'TroopTrak',
        body: ErrorView(message: 'Page not found.'),
      );
}

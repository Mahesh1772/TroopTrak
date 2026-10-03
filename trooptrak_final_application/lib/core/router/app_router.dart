import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/feedback_views.dart';
import 'app_routes.dart';

typedef RouteWidgetBuilder = Widget Function(
    BuildContext context, Object? arguments);

abstract final class AppRouter {
  static final Map<String, RouteWidgetBuilder> _routes = {
    AppRoutes.root: (_, __) => const _PlaceholderHome(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = _routes[settings.name] ?? (_, __) => const _UnknownRoute();
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) => builder(context, settings.arguments),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) => const AppScaffold(
        body: EmptyState(message: 'TroopTrak', image: null),
      );
}

class _UnknownRoute extends StatelessWidget {
  const _UnknownRoute();

  @override
  Widget build(BuildContext context) => const AppScaffold(
        title: 'TroopTrak',
        body: ErrorView(message: 'Page not found.'),
      );
}

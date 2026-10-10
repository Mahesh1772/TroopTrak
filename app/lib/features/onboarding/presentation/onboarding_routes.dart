import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/route_builder.dart';
import '../domain/usecases/role_usecases.dart';
import 'pages/role_selection_page.dart';
import 'pages/splash_page.dart';
import 'providers/role_selection_provider.dart';

final Map<String, RouteWidgetBuilder> onboardingRoutes = {
  AppRoutes.root: (_, __) => const SplashPage(),
  AppRoutes.roleSelection: (context, _) => ChangeNotifierProvider(
        create: (_) => RoleSelectionProvider(context.read<SetRole>()),
        child: const RoleSelectionPage(),
      ),
};

import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/route_builder.dart';
import '../../soldiers/domain/usecases/soldier_usecases.dart';
import 'pages/soldier_profile_page.dart';
import 'profile_capabilities.dart';
import 'providers/soldier_profile_provider.dart';

/// `AppRoutes.soldierProfile` takes the `Users` doc id as its argument.
final Map<String, RouteWidgetBuilder> soldierProfileRoutes = {
  AppRoutes.soldierProfile: (context, arguments) => ChangeNotifierProvider(
        create: (context) => SoldierProfileProvider(
            context.read<WatchSoldier>()(arguments! as String)),
        child: const SoldierProfilePage(
          capabilities: ProfileCapabilities.commanderViewingSoldier,
        ),
      ),
};

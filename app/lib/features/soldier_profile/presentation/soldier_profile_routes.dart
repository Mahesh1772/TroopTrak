import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/route_builder.dart';
import '../../soldiers/domain/usecases/soldier_usecases.dart';
import 'pages/soldier_profile_page.dart';
import 'profile_actions.dart';
import 'profile_capabilities.dart';
import 'providers/soldier_profile_provider.dart';

ProfileActions _commanderActions(BuildContext context) => ProfileActions(
      edit: (context, soldier) => Navigator.of(context)
          .pushNamed(AppRoutes.editSoldier, arguments: soldier),
      delete: (soldier) => context.read<DeleteSoldier>()(soldier.id),
      afterDelete: (navigator) => navigator.pop(),
    );

/// `AppRoutes.soldierProfile` takes the `Users` doc id as its argument.
final Map<String, RouteWidgetBuilder> soldierProfileRoutes = {
  AppRoutes.soldierProfile: (context, arguments) => ChangeNotifierProvider(
        create: (context) => SoldierProfileProvider(
            context.read<WatchSoldier>()(arguments! as String)),
        child: SoldierProfilePage(
          capabilities: ProfileCapabilities.commanderViewingSoldier,
          actions: _commanderActions(context),
        ),
      ),
};

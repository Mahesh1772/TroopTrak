import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/route_builder.dart';
import '../../attendance/domain/usecases/attendance_usecases.dart';
import '../../attendance/domain/usecases/watch_soldiers_in_camp.dart';
import '../../soldiers/domain/entities/soldier.dart';
import 'pages/nominal_roll_page.dart';
import 'pages/soldier_form_page.dart';
import 'providers/nominal_roll_provider.dart';

/// Commander shell tab; [currentUserId] is the signed-in commander's Users id.
Widget nominalRollTab(BuildContext context, {String? currentUserId}) =>
    ChangeNotifierProvider(
      create: (context) => NominalRollProvider(
        watch: context.read<WatchSoldiersInCamp>(),
        bookInOut: context.read<BookInOut>(),
        excludeId: currentUserId,
      ),
      child: const NominalRollPage(),
    );

/// Add takes an optional prefill (a scanned registration); edit takes the soldier.
final Map<String, RouteWidgetBuilder> soldierFormRoutes = {
  AppRoutes.addSoldier: (_, arguments) => SoldierFormPage(
      mode: SoldierFormMode.add, initial: arguments as Soldier?),
  AppRoutes.editSoldier: (_, arguments) => SoldierFormPage(
      mode: SoldierFormMode.edit, initial: arguments! as Soldier),
};

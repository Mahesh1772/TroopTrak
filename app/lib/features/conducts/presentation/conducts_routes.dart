import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/route_builder.dart';
import '../../../core/services/clock.dart';
import '../../soldiers/domain/usecases/soldier_usecases.dart';
import '../domain/entities/conduct.dart';
import '../domain/usecases/build_conduct_roster.dart';
import '../domain/usecases/conduct_usecases.dart';
import '../domain/usecases/watch_conduct_breakdown.dart';
import 'pages/conduct_details_page.dart';
import 'pages/conduct_form_page.dart';
import 'pages/conduct_tracker_page.dart';
import 'providers/conduct_details_provider.dart';
import 'providers/conduct_form_provider.dart';
import 'providers/conduct_tracker_provider.dart';

/// Shell tab for commanders.
Widget conductTrackerTab(BuildContext context) => _tracker(context);

/// Soldier shell tab (R13): read-only, marks the conducts [participant] is in.
Widget soldierConductTrackerTab(BuildContext context, String participant) =>
    _tracker(context, participant: participant);

Widget _tracker(BuildContext context, {String? participant}) =>
    ChangeNotifierProvider(
      create: (context) => ConductTrackerProvider(
        watchOnDay: context.read<WatchConductsOnDay>(),
        watchSoldiers: context.read<WatchSoldiers>(),
        clock: context.read<Clock>(),
        participant: participant,
      ),
      child: ConductTrackerPage(
        canManage: participant == null,
        showTitle: participant != null,
      ),
    );

Widget _form(BuildContext context, Conduct? initial) => ChangeNotifierProvider(
      create: (context) => ConductFormProvider(
        watchSoldiers: context.read<WatchSoldiers>(),
        buildRoster: context.read<BuildConductRoster>(),
        add: context.read<AddConduct>(),
        update: context.read<UpdateConduct>(),
        initial: initial,
      ),
      child: const ConductFormPage(),
    );

Widget _details(BuildContext context, String conductId,
        {required bool canManage}) =>
    ChangeNotifierProvider(
      create: (context) => ConductDetailsProvider(
        watch: context.read<WatchConductBreakdown>(),
        delete: context.read<DeleteConduct>(),
        conductId: conductId,
      ),
      child: ConductDetailsPage(canManage: canManage),
    );

/// Edit takes the conduct being changed; details take the conduct id.
final Map<String, RouteWidgetBuilder> conductRoutes = {
  AppRoutes.addConduct: (context, _) => _form(context, null),
  AppRoutes.editConduct: (context, arguments) =>
      _form(context, arguments! as Conduct),
  AppRoutes.conductDetails: (context, arguments) =>
      _details(context, arguments! as String, canManage: true),
  AppRoutes.conductDetailsReadOnly: (context, arguments) =>
      _details(context, arguments! as String, canManage: false),
};

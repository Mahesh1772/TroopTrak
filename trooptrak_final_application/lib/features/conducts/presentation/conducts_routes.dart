import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/services/clock.dart';
import '../../soldiers/domain/usecases/soldier_usecases.dart';
import '../domain/usecases/conduct_usecases.dart';
import 'pages/conduct_tracker_page.dart';
import 'providers/conduct_tracker_provider.dart';

/// Shell tab for both roles; only commanders can add conducts.
Widget conductTrackerTab(BuildContext context, {bool canManage = true}) =>
    ChangeNotifierProvider(
      create: (context) => ConductTrackerProvider(
        watchOnDay: context.read<WatchConductsOnDay>(),
        watchSoldiers: context.read<WatchSoldiers>(),
        clock: context.read<Clock>(),
      ),
      child: ConductTrackerPage(canManage: canManage),
    );

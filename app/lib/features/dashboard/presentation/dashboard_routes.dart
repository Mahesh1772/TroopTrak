import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/services/clock.dart';
import '../domain/usecases/watch_calendar_events.dart';
import '../domain/usecases/watch_strength_summary.dart';
import 'pages/dashboard_page.dart';
import 'providers/dashboard_providers.dart';

/// Commander shell Home tab; [name] is the signed-in commander's name.
Widget dashboardTab(BuildContext context, {required String name}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => StrengthProvider(
              context.read<WatchStrengthSummary>(), context.read<Clock>()),
        ),
        ChangeNotifierProvider(
          create: (context) => EventCalendarProvider(
              context.read<WatchCalendarEvents>(), context.read<Clock>()),
        ),
      ],
      child: DashboardPage(name: name),
    );

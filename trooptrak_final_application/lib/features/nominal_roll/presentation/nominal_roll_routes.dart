import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../attendance/domain/usecases/attendance_usecases.dart';
import '../../attendance/domain/usecases/watch_soldiers_in_camp.dart';
import 'pages/nominal_roll_page.dart';
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

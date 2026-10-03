import 'package:flutter/material.dart';

import '../../features/shell/presentation/pages/soldier_shell.dart';
import '../widgets/feedback_views.dart';

/// Soldier shell; tabs not rebuilt yet show placeholders.
class SoldierHome extends StatelessWidget {
  const SoldierHome({super.key});

  @override
  Widget build(BuildContext context) => SoldierShell(
        profile: (_) => const EmptyState(message: 'My Profile', image: null),
        conductTracker: (_) =>
            const EmptyState(message: 'Conduct Tracker', image: null),
        guardDuty: (_) => const EmptyState(message: 'Guard Duty', image: null),
      );
}

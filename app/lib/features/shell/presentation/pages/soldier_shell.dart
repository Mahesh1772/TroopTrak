import 'package:flutter/material.dart';

import '../widgets/shell_scaffold.dart';
import '../widgets/shell_tab.dart';

/// Rebuild of `P2/util/new_navbar.dart`: My Profile, Conduct Tracker and
/// Guard Duty without an app bar; follows the app theme (D6).
class SoldierShell extends StatelessWidget {
  const SoldierShell({
    super.key,
    required this.profile,
    required this.conductTracker,
    required this.guardDuty,
  });

  final WidgetBuilder profile;
  final WidgetBuilder conductTracker;
  final WidgetBuilder guardDuty;

  @override
  Widget build(BuildContext context) => ShellScaffold(
        showAppBar: false,
        tabs: [
          ShellTab(
            key: 'myProfile',
            label: 'My Profile',
            title: 'My Profile',
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            builder: profile,
          ),
          ShellTab(
            key: 'conductTracker',
            label: 'Conducts',
            title: 'Conduct Tracker',
            icon: Icons.track_changes_rounded,
            builder: conductTracker,
          ),
          ShellTab(
            key: 'guardDuty',
            label: 'Guard Duty',
            title: 'Guard Duty',
            icon: Icons.safety_check_outlined,
            selectedIcon: Icons.safety_check_rounded,
            builder: guardDuty,
          ),
        ],
      );
}

import 'package:flutter/material.dart';

import '../../../../core/widgets/dark_section.dart';
import '../widgets/shell_scaffold.dart';

/// Rebuild of `P2/util/new_navbar.dart`: My Profile, Conduct Tracker and
/// Guard Duty, always dark and without an app bar, as the source.
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
  Widget build(BuildContext context) => DarkSection(
        child: ShellScaffold(
          showAppBar: false,
          tabs: [
            ShellTab(
              key: 'myProfile',
              label: 'My Profile',
              title: 'My Profile',
              icon: Icons.person,
              builder: profile,
            ),
            ShellTab(
              key: 'conductTracker',
              label: 'Conduct Tracker',
              title: 'Conduct Tracker',
              icon: Icons.track_changes_rounded,
              builder: conductTracker,
            ),
            ShellTab(
              key: 'guardDuty',
              label: 'Guard Duty',
              title: 'Guard Duty',
              icon: Icons.safety_check,
              builder: guardDuty,
            ),
          ],
        ),
      );
}

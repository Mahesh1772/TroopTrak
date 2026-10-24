import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../providers/commander_rank_provider.dart';
import '../widgets/commander_avatar.dart';
import '../widgets/shell_scaffold.dart';
import '../widgets/shell_tab.dart';

/// Rebuild of `CMD/util/new_navbar.dart`. Tab content comes from the router so
/// the shell never imports another feature's pages. Needs a
/// [CommanderRankProvider] above it for the app bar avatar.
class CommanderShell extends StatelessWidget {
  const CommanderShell({
    super.key,
    required this.home,
    required this.nominalRoll,
    required this.conductTracker,
    required this.guardDuty,
  });

  final WidgetBuilder home;
  final WidgetBuilder nominalRoll;
  final WidgetBuilder conductTracker;
  final WidgetBuilder guardDuty;

  @override
  Widget build(BuildContext context) {
    return ShellScaffold(
      tabs: [
        ShellTab(
          key: 'home',
          label: 'Home',
          title: 'Dashboard',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          builder: home,
        ),
        ShellTab(
          key: 'nominalRoll',
          label: 'Nominal Roll',
          title: 'Nominal Roll',
          icon: Icons.perm_contact_calendar_outlined,
          selectedIcon: Icons.perm_contact_calendar_rounded,
          builder: nominalRoll,
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
      actions: [
        Selector<CommanderRankProvider, String?>(
          selector: (_, provider) => provider.rank,
          builder: (context, rank, _) => CommanderAvatar(
            key: const Key('userProfileIcon'),
            rank: rank ?? '',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.commanderProfile),
          ),
        ),
      ],
    );
  }
}

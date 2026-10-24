import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/icon_tab.dart';
import '../../../../core/widgets/page_title.dart';
import '../widgets/leaderboard_tab.dart';
import '../widgets/upcoming_duties_tab.dart';

/// Rebuild of `guard_duty_tracker_screen.dart` (both roles): leaderboard and
/// upcoming duties tabs; commanders get the add-duty button. Streams keep both
/// tabs current, so the source's refresh callback is not needed. [showTitle]
/// heads the page where the shell has no app bar (soldier side).
class GuardDutyPage extends StatelessWidget {
  const GuardDutyPage({
    super.key,
    this.canManage = true,
    this.showTitle = false,
  });

  final bool canManage;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: canManage
            ? FloatingActionButton(
                key: const Key('addDuty'),
                heroTag: null,
                tooltip: 'Add guard duty',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.addDuty),
                child: const Icon(Icons.add),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              if (showTitle) const PageTitle('Guard Duty'),
              const TabBar(
                tabs: [
                  IconTab(
                    icon: Icons.leaderboard_rounded,
                    label: 'LEADERBOARD',
                  ),
                  IconTab(icon: Icons.more_time_rounded, label: 'UPCOMING'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    const LeaderboardTab(),
                    UpcomingDutiesTab(canManage: canManage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

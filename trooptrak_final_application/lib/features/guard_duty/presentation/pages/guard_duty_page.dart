import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../widgets/leaderboard_tab.dart';
import '../widgets/upcoming_duties_tab.dart';

/// Rebuild of `guard_duty_tracker_screen.dart`: leaderboard and upcoming
/// duties tabs; commanders get the add-duty button. Streams keep both tabs
/// current, so the source's refresh callback is not needed.
class GuardDutyPage extends StatelessWidget {
  const GuardDutyPage({super.key, this.canManage = true});

  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final style = context.textStyles.titleSmall
        ?.copyWith(fontSize: 15.sp, letterSpacing: 1.5);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: canManage
            ? FloatingActionButton(
                key: const Key('addDuty'),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.addDuty),
                child: const Icon(Icons.add),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
                labelStyle: style,
                unselectedLabelStyle: style,
                tabs: const [
                  Tab(
                      text: 'POINTS LEADERBOARD',
                      icon: Icon(Icons.leaderboard_rounded)),
                  Tab(
                      text: 'UPCOMING DUTIES',
                      icon: Icon(Icons.more_time_rounded)),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../widgets/shell_scaffold.dart';

/// Rebuild of `CMD/util/new_navbar.dart`. Tab content comes from the router so
/// the shell never imports another feature's pages.
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
          builder: home,
        ),
        ShellTab(
          key: 'nominalRoll',
          label: 'Nominal Roll',
          title: 'Nominal Roll',
          icon: Icons.perm_contact_calendar_rounded,
          builder: nominalRoll,
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
      actions: [
        InkWell(
          key: const Key('userProfileIcon'),
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.commanderProfile),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md.sp),
            child: Image.asset(
              'lib/assets/icons8-user-96.png',
              width: 50.w,
              color: context.isDark ? AppColors.white : null,
            ),
          ),
        ),
      ],
    );
  }
}

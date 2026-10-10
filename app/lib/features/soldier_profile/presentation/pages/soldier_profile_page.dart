import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/clock.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../attendance/domain/usecases/attendance_usecases.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../statuses/domain/usecases/status_usecases.dart';
import '../profile_actions.dart';
import '../profile_capabilities.dart';
import '../providers/attendance_provider.dart';
import '../providers/soldier_profile_provider.dart';
import '../providers/statuses_provider.dart';
import '../widgets/attendance_tab.dart';
import '../widgets/basic_info_tab.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_header_actions.dart';
import '../widgets/statuses_tab.dart';

/// Rebuild of `CMD/screens/detailed_screen/soldier_detailed_screen.dart`
/// and the own-profile screens of both roles.
class SoldierProfilePage extends StatelessWidget {
  const SoldierProfilePage({
    super.key,
    required this.capabilities,
    required this.actions,
    this.headerActions = const [],
    this.inShell = false,
  });

  final ProfileCapabilities capabilities;
  final ProfileActions actions;

  /// Extra header buttons (the soldier's SHOW QR CODE).
  final List<Widget> headerActions;

  /// Shown as a shell tab: no back button and sign out as a top-right icon,
  /// as the source soldier profile.
  final bool inShell;

  Future<void> _signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    final result = await actions.signOut!();
    result.fold(
      (f) {
        if (context.mounted) AppSnackbar.error(context, f.message);
      },
      (_) => actions.afterSignOut?.call(navigator),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SoldierProfileProvider>().state;
    final canSignOut = capabilities.showSignOut && actions.signOut != null;
    final header = [
      if (canSignOut && !inShell)
        HeaderPillButton(
          key: const Key('signOutButton'),
          label: 'SIGN OUT',
          icon: Icons.exit_to_app_rounded,
          onPressed: () => _signOut(context),
        ),
      if (capabilities.showThemeToggle) const ThemeToggle(),
      ...headerActions,
    ];
    return Scaffold(
      body: StateView<Soldier>(
        state: state,
        builder: (context, soldier) => MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => StatusesProvider(
                watch: context.read<WatchSoldierStatuses>(),
                delete: context.read<DeleteStatus>(),
                clock: context.read<Clock>(),
                soldierId: soldier.id,
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => AttendanceProvider(
                watch: context.read<WatchAttendance>(),
                delete: context.read<DeleteAttendance>(),
                soldierId: soldier.id,
              ),
            ),
          ],
          child: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ProfileHeader(
                        soldier: soldier,
                        actions: header,
                        showBack: !inShell,
                        topTrailing: canSignOut && inShell
                            ? IconButton(
                                key: const Key('signOutIcon'),
                                onPressed: () => _signOut(context),
                                icon: Icon(Icons.exit_to_app_rounded,
                                    color: AppColors.white, size: 35.sp),
                              )
                            : null,
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      const _ProfileTabBar(),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  BasicInfoTab(
                    soldier: soldier,
                    capabilities: capabilities,
                    actions: actions,
                  ),
                  StatusesTab(canManage: capabilities.canManageStatuses),
                  AttendanceTab(canManage: capabilities.canManageAttendance),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTabBar extends StatelessWidget {
  const _ProfileTabBar();

  @override
  Widget build(BuildContext context) {
    final style = context.textStyles.titleSmall
        ?.copyWith(fontSize: 15.sp, letterSpacing: 1.5);
    return TabBar(
      indicatorColor: AppColors.brandIndigo,
      labelStyle: style,
      unselectedLabelStyle: style,
      unselectedLabelColor: context.colors.onSurface,
      tabs: const [
        Tab(text: 'BASIC INFO', icon: Icon(Icons.info)),
        Tab(text: 'STATUSES', icon: Icon(Icons.warning_rounded)),
        Tab(text: 'ATTENDANCE', icon: Icon(Icons.person_add_alt_1)),
      ],
    );
  }
}

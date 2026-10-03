import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../profile_capabilities.dart';
import '../providers/soldier_profile_provider.dart';
import '../widgets/profile_header.dart';

/// Rebuild of `CMD/screens/detailed_screen/soldier_detailed_screen.dart`
/// and the own-profile screens of both roles.
class SoldierProfilePage extends StatelessWidget {
  const SoldierProfilePage({
    super.key,
    required this.capabilities,
    this.headerActions = const [],
  });

  final ProfileCapabilities capabilities;
  final List<Widget> headerActions;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SoldierProfileProvider>().state;
    return Scaffold(
      body: StateView<Soldier>(
        state: state,
        builder: (context, soldier) => DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    ProfileHeader(soldier: soldier, actions: headerActions),
                    SizedBox(height: AppSpacing.sm.h),
                    const _ProfileTabBar(),
                  ],
                ),
              ),
            ],
            body: const TabBarView(
              children: [
                _TabPlaceholder('Basic info'),
                _TabPlaceholder('Statuses'),
                _TabPlaceholder('Attendance'),
              ],
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

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => EmptyState(message: label, image: null);
}

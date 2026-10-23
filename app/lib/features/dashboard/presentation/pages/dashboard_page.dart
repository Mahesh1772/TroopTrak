import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../../core/widgets/gradient_header.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/event_calendar.dart';
import '../widgets/overlap_up.dart';
import '../widgets/parade_card.dart';

enum _DashboardView { strength, calendar }

/// Rebuild of `CMD/screens/dashboard_screen/dashboard_screen.dart`: a gradient
/// header with the welcome and a Strength / Calendar switch, then the parade
/// card or the conduct / duty calendar.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.name});

  final String name;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  _DashboardView _view = _DashboardView.strength;

  @override
  Widget build(BuildContext context) {
    final strength = _view == _DashboardView.strength;
    return ListView(
      padding: EdgeInsets.only(bottom: AppSpacing.xxl.h),
      children: [
        GradientHeader(
          bottom:
              strength ? AppLayout.overlapHeaderBottom : AppLayout.headerBottom,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xs.w,
                    0,
                    AppSpacing.xs.w,
                    AppSpacing.lg.h,
                  ),
                  child: Text(
                    'Welcome, ${widget.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.barlow(
                        17, FontWeight.w400, AppColors.onGradientGreeting),
                  ),
                ),
                AppSegmentedControl<_DashboardView>(
                  glass: true,
                  selected: _view,
                  onChanged: (view) => setState(() => _view = view),
                  segments: const [
                    AppSegment(
                      value: _DashboardView.strength,
                      label: 'Strength',
                      icon: Icons.groups_rounded,
                      key: Key('showStrength'),
                    ),
                    AppSegment(
                      value: _DashboardView.calendar,
                      label: 'Calendar',
                      icon: Icons.calendar_month_rounded,
                      key: Key('showCalendar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (strength)
          OverlapUp(
            overlap: AppLayout.headerOverlap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
              child: const _StrengthCard(),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg.w,
              AppSpacing.lg.h,
              AppSpacing.lg.w,
              0,
            ),
            child: const _CalendarHost(),
          ),
      ],
    );
  }
}

class _StrengthCard extends StatelessWidget {
  const _StrengthCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StrengthProvider>();
    return ParadeCard(
      state: provider.state,
      stamp: provider.stamp,
      onOpenSoldier: (id) => Navigator.of(context)
          .pushNamed(AppRoutes.soldierProfile, arguments: id),
    );
  }
}

class _CalendarHost extends StatelessWidget {
  const _CalendarHost();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.palette.card,
          borderRadius: BorderRadius.circular(AppRadii.xl.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md.r),
          child: const EventCalendar(),
        ),
      );
}

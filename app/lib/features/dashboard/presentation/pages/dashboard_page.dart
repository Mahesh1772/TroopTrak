import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/expandable_count_tile.dart';
import '../../../../core/widgets/soldier_card.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/entities/strength_summary.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/event_calendar.dart';
import '../widgets/strength_chart.dart';

/// Rebuild of `CMD/screens/dashboard_screen/dashboard_screen.dart`: welcome,
/// then a flip card with the strength breakdown on the front and the
/// conduct / duty calendar on the back.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.name});

  final String name;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _flip = FlipCardController();

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return ListView(
      padding: EdgeInsets.only(bottom: 30.h),
      children: [
        SizedBox(height: AppSpacing.sm.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl.w),
          child: Text('Welcome,\n${widget.name}! 👋',
              style: text.displayLarge?.copyWith(fontSize: 32.sp)),
        ),
        SizedBox(height: AppSpacing.xl.h),
        FlipCard(
          controller: _flip,
          flipOnTouch: false,
          front: _Card(child: _StrengthFront(onFlip: _flip.toggleCard)),
          back: _Card(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: const Key('showStrength'),
                    onPressed: _flip.toggleCard,
                    icon: const Icon(Icons.pie_chart_rounded),
                    label: const Text('Show Strength'),
                  ),
                ),
                const EventCalendar(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.md.r);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
      child: DecoratedBox(
        decoration:
            BoxDecoration(boxShadow: AppShadows.tile, borderRadius: radius),
        child: Material(
          color: context.colors.primary,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg.sp),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _StrengthFront extends StatelessWidget {
  const _StrengthFront({required this.onFlip});

  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StrengthProvider>();
    final text = context.textStyles;
    final muted = text.bodyMedium?.color?.withValues(alpha: 0.45);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Strength In-Camp', style: text.displayMedium),
                  Text('As of ${provider.stamp}',
                      style: text.titleLarge?.copyWith(color: muted)),
                ],
              ),
            ),
            InkWell(
              key: const Key('showCalendar'),
              onTap: onFlip,
              child: Column(
                children: [
                  Icon(Icons.date_range_rounded, size: 30.sp),
                  Text('Show Calendar', style: text.bodySmall),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg.h),
        StateView<StrengthSummary>(
          state: provider.state,
          builder: (context, s) => Column(
            children: [
              StrengthChart(summary: s),
              SizedBox(height: AppSpacing.lg.h),
              _BreakdownTile(
                title: 'Total Officers',
                icon: 'lib/assets/icons8-medals-64.png',
                color: AppColors.chartOfficers,
                current: s.officersInCamp,
                total: s.officers.length,
              ),
              _BreakdownTile(
                title: 'Total WOSEs',
                icon: 'lib/assets/icons8-soldier-man-64.png',
                color: AppColors.chartWoses,
                current: s.wosesInCamp,
                total: s.woses.length,
              ),
              _BreakdownTile(
                title: 'On Status',
                icon: 'lib/assets/icons8-error-64.png',
                color: AppColors.chartStatus,
                current: s.onStatus,
                total: s.total,
              ),
              _BreakdownTile(
                title: 'On MA',
                icon: 'lib/assets/icons8-doctors-folder-64.png',
                color: AppColors.chartMedical,
                current: s.onMa,
                total: s.total,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rebuild of `current_strength_breakdown_tile.dart` on the shared tile.
class _BreakdownTile extends StatelessWidget {
  const _BreakdownTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.current,
    required this.total,
  });

  final String title;
  final String icon;
  final Color color;
  final List<Soldier> current;
  final int total;

  @override
  Widget build(BuildContext context) => ExpandableCountTile(
        key: Key('tile-$title'),
        title: title,
        subtitle: '${current.length} In Camp',
        count: '${current.length} / $total',
        leading: Image.asset(icon,
            color: color, errorBuilder: (_, __, ___) => const SizedBox()),
        children: [
          for (final s in current)
            SoldierCard(
              name: s.name,
              rank: s.rank,
              onTap: () => Navigator.of(context)
                  .pushNamed(AppRoutes.soldierProfile, arguments: s.id),
            ),
        ],
      );
}

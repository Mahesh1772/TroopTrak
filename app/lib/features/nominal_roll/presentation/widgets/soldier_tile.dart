import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/ranks.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/rank_avatar.dart';
import '../../../soldiers/domain/entities/soldier.dart';

/// Rebuild of `nominal_roll_screen/util/solider_tile.dart` (R4, R10).
class SoldierTile extends StatelessWidget {
  const SoldierTile({
    super.key,
    required this.soldier,
    required this.onTap,
    required this.onToggle,
  });

  final Soldier soldier;
  final VoidCallback onTap;

  /// Completes when the booking is written; the switch spins until then.
  final Future<void> Function(bool isInCamp) onToggle;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final radius = Radius.circular(AppRadii.lg.r);
    return Padding(
      padding: EdgeInsets.all(AppSpacing.sm.sp),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius),
          boxShadow: AppShadows.tile,
          color: AppColors.rankTile(Ranks.groupOf(soldier.rank)),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: Key('soldierTile-${soldier.id}'),
            onTap: onTap,
            borderRadius: BorderRadius.all(radius),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    padding: EdgeInsets.all(5.sp),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.only(
                          topRight: radius, bottomLeft: radius),
                    ),
                    child: RankAvatar.insignia(soldier.rank, size: 30.w),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl.w, vertical: AppSpacing.sm.h),
                  child: RankAvatar.person(soldier.rank, size: 90.w),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
                  child: SizedBox(
                    height: 40.h,
                    child: Center(
                      child: AutoSizeText(
                        soldier.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style:
                            text.displaySmall?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  soldier.isInCamp ? 'IN CAMP' : 'NOT IN CAMP',
                  style: text.bodySmall?.copyWith(color: AppColors.white),
                ),
                SizedBox(height: 15.h),
                AnimatedToggleSwitch<bool>.rolling(
                  key: Key('inCampToggle-${soldier.id}'),
                  current: soldier.isInCamp,
                  values: const [false, true],
                  onChanged: onToggle,
                  height: 40.h,
                  spacing: 10.w,
                  borderWidth: 3.w,
                  iconBuilder: (value, _) => Icon(
                      value ? Icons.check_circle : Icons.cancel,
                      key: Key('inCamp-$value')),
                  style: ToggleStyle(
                    indicatorColor: context.colors.primary,
                    backgroundColor: AppColors.warning,
                    borderColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

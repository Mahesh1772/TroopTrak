import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/ranks.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';
import 'rank_avatar.dart';

/// Rank-coloured mini card with person icon, insignia and name; the source
/// drew it for duty participants and dashboard breakdowns.
class SoldierCard extends StatelessWidget {
  const SoldierCard({
    super.key,
    required this.name,
    required this.rank,
    this.onTap,
  });

  final String name;
  final String rank;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.lg.r);
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md.sp),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.rankTile(Ranks.groupOf(rank)),
          borderRadius: radius,
          boxShadow: AppShadows.tile,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              width: 200.w,
              padding: EdgeInsets.all(AppSpacing.md.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RankAvatar.person(rank, size: 60.w),
                      RankAvatar.insignia(rank, size: 30.w, tint: false),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  AutoSizeText(
                    name,
                    maxLines: 2,
                    style: context.textStyles.displaySmall
                        ?.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

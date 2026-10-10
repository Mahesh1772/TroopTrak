import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';
import 'rank_avatar.dart';

class PersonTile extends StatelessWidget {
  const PersonTile({
    super.key,
    required this.name,
    required this.rank,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.muted = false,
  });

  final String name;
  final String rank;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final alpha = muted ? 0.35 : 1.0;
    final onTile = context.palette.onTile.withValues(alpha: alpha);
    final text = context.textStyles;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Material(
        color: muted
            ? AppColors.personTileMuted.withValues(alpha: 0.35)
            : context.palette.personTile,
        borderRadius: BorderRadius.circular(AppRadii.md.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md.r),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md.r),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor:
                      AppColors.personTile.withValues(alpha: muted ? 0.35 : 1),
                  child: RankAvatar.insignia(
                    rank,
                    size: 30.w,
                    color: muted ? onTile : null,
                  ),
                ),
                SizedBox(width: AppSpacing.xxl.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium?.copyWith(color: onTile)),
                      if (subtitle != null)
                        Text(subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelSmall?.copyWith(
                              color: AppColors.white70
                                  .withValues(alpha: alpha * 0.7),
                            )),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

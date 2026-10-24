import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/ranks.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_text_styles.dart';

const _fontSize = 12.5;
const _tracking = 0.05;
const _padX = 6.0;
const _padY = 3.0;

/// The rank's letters on its group colour.
class RankChip extends StatelessWidget {
  const RankChip(this.rank, {super.key});

  final String rank;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.figure(
      _fontSize,
      FontWeight.w600,
      AppColors.white,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.rankTile(Ranks.groupOf(rank)),
        borderRadius: BorderRadius.circular(AppRadii.xs.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _padX.w, vertical: _padY.h),
        child: Text(
          rank,
          maxLines: 1,
          style: style.copyWith(
            height: 1,
            letterSpacing: style.fontSize! * _tracking,
          ),
        ),
      ),
    );
  }
}

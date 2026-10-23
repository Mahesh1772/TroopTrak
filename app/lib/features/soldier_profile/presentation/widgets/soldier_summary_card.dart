import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/rank_plate.dart';
import '../../../soldiers/domain/entities/soldier.dart';

/// Whose record a form edits: rank plate, name, and "rank · appointment".
class SoldierSummaryCard extends StatelessWidget {
  const SoldierSummaryCard({super.key, required this.soldier});

  final Soldier soldier;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.control.w,
        vertical: AppSpacing.md.h,
      ),
      child: Row(
        spacing: AppSpacing.md.w,
        children: [
          RankPlate(soldier.rank),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  soldier.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3(palette.onCard),
                ),
                Text(
                  '${soldier.rank} · ${soldier.appointment}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(palette.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

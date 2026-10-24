import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/number_formats.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/fraction_bar.dart';
import '../../../../core/widgets/rank_plate.dart';
import '../../../../core/widgets/state_tone.dart';
import '../../../soldiers/domain/entities/soldier.dart';

/// One soldier: rank plate, name over rank, then a points bar and the figure.
/// [fraction] is the bar length (0 to 1); [isSelf] tints the row and adds
/// "You" beside the rank. The bar is keyed `bar-<id>`.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.soldier,
    required this.fraction,
    this.isSelf = false,
  });

  final Soldier soldier;
  final double fraction;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final row = AppListRow(
      title: soldier.name,
      leading: SizedBox(
        width: AppLayout.leaderboardRankColumn.w,
        child: Align(
          alignment: Alignment.centerLeft,
          child: RankPlate(soldier.rank, size: RankPlate.sm),
        ),
      ),
      subtitle: Text(isSelf ? '${soldier.rank} · You' : soldier.rank),
      trailing: SizedBox(
        width: AppLayout.leaderboardPointsColumn.w,
        child: Row(
          spacing: AppSpacing.sm.w,
          children: [
            Expanded(
              child: FractionBar(
                fillKey: Key('bar-${soldier.id}'),
                fraction: fraction,
                height: AppLayout.leaderboardBar,
              ),
            ),
            SizedBox(
              width: AppLayout.leaderboardFigure.w,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  formatPoints(soldier.points),
                  maxLines: 1,
                  style: AppTextStyles.figure(
                    18,
                    FontWeight.w600,
                    palette.onCard,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return isSelf
        ? ColoredBox(
            key: Key('self-${soldier.id}'),
            color: StateTone.accent.tint(palette),
            child: row,
          )
        : row;
  }
}

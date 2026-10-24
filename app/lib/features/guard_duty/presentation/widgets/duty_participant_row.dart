import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/rank_chip.dart';
import '../../../../core/widgets/rank_plate.dart';
import '../../../../core/widgets/state_chip.dart';
import '../../../../core/widgets/state_tone.dart';

const _nameSize = 15.0;

/// One participant inside a duty card: plate, name with a "You" chip when it
/// is the signed-in soldier, and the rank chip.
class DutyParticipantRow extends StatelessWidget {
  const DutyParticipantRow({
    super.key,
    required this.name,
    required this.rank,
    this.isSelf = false,
  });

  final String name;
  final String rank;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppLayout.dutyParticipantVertical.h,
      ),
      child: Row(
        spacing: AppSpacing.tight.w,
        children: [
          RankPlate(rank, size: RankPlate.sm),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.sm.w,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.barlow(
                        _nameSize,
                        FontWeight.w500,
                        palette.onCard,
                      ),
                    ),
                  ),
                  if (isSelf) const StateChip('You', tone: StateTone.accent),
                ],
              ),
            ),
          ),
          RankChip(rank),
        ],
      ),
    );
  }
}

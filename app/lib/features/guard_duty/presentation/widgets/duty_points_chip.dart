import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/number_formats.dart';
import '../../../../core/widgets/state_tone.dart';

const _padX = 9.0;
const _figureSize = 16.0;
const _unitSize = 12.0;
const _unitTracking = 0.06;

/// A duty's points on an accent pill, such as "1.5 PTS".
class DutyPointsChip extends StatelessWidget {
  const DutyPointsChip(this.points, {super.key});

  final double points;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const tone = StateTone.accent;
    final color = tone.text(palette);
    final unit = AppTextStyles.figure(_unitSize, FontWeight.w600, color);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: tone.tint(palette),
        shape: const StadiumBorder(),
      ),
      child: SizedBox(
        height: AppLayout.dutyPointsChip.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _padX.w),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: AppSpacing.xxs.w,
              children: [
                Text(
                  formatPoints(points),
                  maxLines: 1,
                  style: AppTextStyles.figure(
                    _figureSize,
                    FontWeight.w600,
                    color,
                  ),
                ),
                Text(
                  'PTS',
                  maxLines: 1,
                  style: unit.copyWith(
                      letterSpacing: unit.fontSize! * _unitTracking),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

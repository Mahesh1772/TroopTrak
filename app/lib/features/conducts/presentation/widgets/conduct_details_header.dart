import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/gradient_header.dart';
import '../../../../core/widgets/header_buttons.dart';
import '../../../../core/widgets/tally_strip.dart';
import '../../domain/usecases/watch_conduct_breakdown.dart';
import 'participation_tally.dart';

/// Gradient header of the conduct details: type, name, date and time, and the
/// participation strip. Edit and delete show only when their callback is set.
class ConductDetailsHeader extends StatelessWidget {
  const ConductDetailsHeader({
    super.key,
    required this.breakdown,
    this.onEdit,
    this.onDelete,
  });

  final ConductBreakdown breakdown;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final conduct = breakdown.conduct;
    final ticks = breakdown.ticks;
    return GradientHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: AppLayout.appBarHeight.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
              child: Row(
                children: [
                  HeaderIconButton(
                    key: const Key('detailsBack'),
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  if (onEdit != null)
                    HeaderIconButton(
                      key: const Key('editConduct'),
                      icon: Icons.edit_rounded,
                      tooltip: 'Edit conduct',
                      onPressed: onEdit!,
                    ),
                  if (onDelete != null)
                    HeaderIconButton(
                      key: const Key('deleteConduct'),
                      icon: Icons.delete_rounded,
                      tooltip: 'Delete conduct',
                      onPressed: onDelete!,
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs.h,
              children: [
                Text(
                  conduct.type.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.overline(AppColors.onGradientSubtitle),
                ),
                Text(
                  conduct.name,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headerTitle(AppColors.white),
                ),
                Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xs.h),
                  child: Text(
                    '${formatDay(conduct.day)} · '
                    '${formatTimeRange(conduct.start, conduct.end)}',
                    style: AppTextStyles.figure(
                      17,
                      FontWeight.w500,
                      AppColors.onGradientSubtitle,
                    ),
                  ),
                ),
                SizedBox(height: AppLayout.conductDetailsStripTop.h),
                TallyStrip(
                  onGradient: true,
                  tickHeight: AppLayout.conductDetailsTick,
                  groups: [
                    TallyGroup(
                      label: 'Participation strength',
                      figure: '${ticks.participating} / ${ticks.total}',
                      ticks: participationTallyTicks(ticks),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

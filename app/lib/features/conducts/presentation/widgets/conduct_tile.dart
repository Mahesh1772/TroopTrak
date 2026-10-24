import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/tally_strip.dart';
import '../../domain/entities/conduct.dart';
import '../../domain/services/participation_ticks.dart';
import 'participation_tally.dart';

/// One conduct in the tracker list. With [participating] set (the soldier
/// side) the badge is a tick or a cross, keyed `participating-<id>` or
/// `notParticipating-<id>`; without it the badge counts the participants and
/// is keyed `count-<id>`.
class ConductTile extends StatelessWidget {
  const ConductTile({
    super.key,
    required this.conduct,
    required this.ticks,
    required this.onTap,
    this.participating,
  });

  final Conduct conduct;
  final ParticipationTicks ticks;
  final VoidCallback onTap;
  final bool? participating;

  String get _caption {
    final self = ticks.self;
    return switch (participating) {
      null => 'Participation strength',
      true => 'You are participating',
      false => self == null
          ? 'Not participating'
          : 'Not participating · ${conduct.reasonFor(self.soldier.name)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      key: Key('conduct-${conduct.id}'),
      onTap: onTap,
      hoverColor: palette.hover,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.md.w,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xxs.h,
                    children: [
                      Text(
                        conduct.type.toUpperCase(),
                        style: AppTextStyles.columnHeader(palette.accentText),
                      ),
                      Text(
                        conduct.name,
                        style: AppTextStyles.h2(palette.onCard),
                      ),
                      Text(
                        formatTimeRange(conduct.start, conduct.end),
                        style: AppTextStyles.figure(
                          15,
                          FontWeight.w500,
                          palette.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                _Badge(
                  id: conduct.id,
                  count: ticks.participating,
                  participating: participating,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.control.h),
            TallyStrip(
              tickHeight: AppLayout.conductTick,
              groups: [TallyGroup(ticks: participationTallyTicks(ticks))],
            ),
            SizedBox(height: AppSpacing.sm.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: AppSpacing.sm.w,
              children: [
                Expanded(
                  child: Text(
                    _caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(palette.secondaryText),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '${ticks.participating}',
                    style: AppTextStyles.figure(
                      15,
                      FontWeight.w600,
                      palette.onCard,
                    ),
                    children: [
                      TextSpan(
                        text: ' / ${ticks.total}',
                        style: AppTextStyles.figure(
                          15,
                          FontWeight.w500,
                          palette.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.id,
    required this.count,
    required this.participating,
  });

  final String id;
  final int count;
  final bool? participating;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final out = participating == false;
    final key = switch (participating) {
      null => Key('count-$id'),
      true => Key('participating-$id'),
      false => Key('notParticipating-$id'),
    };
    final size = AppLayout.conductBadge;
    return Semantics(
      label: switch (participating) {
        null => null,
        true => 'Participating',
        false => 'Not participating',
      },
      child: Container(
        key: key,
        constraints: BoxConstraints(minWidth: size.r, minHeight: size.r),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.inline.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: out ? palette.cardElevated : null,
          gradient: out
              ? null
              : LinearGradient(
                  colors: palette.headerGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(AppRadii.control.r),
        ),
        child: switch (participating) {
          null => Text(
              '$count',
              style: AppTextStyles.figure(20, FontWeight.w600, AppColors.white),
            ),
          true => Icon(
              Icons.check_rounded,
              size: AppLayout.conductBadgeIcon.r,
              color: AppColors.white,
            ),
          false => Icon(
              Icons.close_rounded,
              size: AppLayout.conductBadgeIcon.r,
              color: palette.secondaryText,
            ),
        },
      ),
    );
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/soldier_card.dart';
import '../../domain/entities/duty.dart';

/// Rebuild of `guard_duty_main_page_tiles.dart`: points badge, time range and
/// date; expands to the participants and (for commanders) edit / delete.
/// With [participating] set (the soldier side) a tick or a cross follows.
class DutyTile extends StatelessWidget {
  const DutyTile({
    super.key,
    required this.duty,
    this.onEdit,
    this.onDelete,
    this.participating,
  });

  final Duty duty;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool? participating;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final white = text.headlineSmall?.copyWith(color: AppColors.white);
    final gap = SizedBox(height: AppSpacing.xl.h);
    return Container(
      key: Key('duty-${duty.id}'),
      margin: EdgeInsets.fromLTRB(
          AppSpacing.sm.w, AppSpacing.lg.h, AppSpacing.sm.w, 0),
      padding: EdgeInsets.all(AppSpacing.lg.sp),
      decoration: BoxDecoration(
        border: Border.all(
            width: 2.w, color: context.colors.tertiary.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(AppSpacing.lg.r),
      ),
      child: Theme(
        data: context.theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          textColor: context.colors.tertiary,
          iconColor: context.colors.tertiary,
          collapsedIconColor: AppColors.chartWoses,
          title: Row(
            children: [
              Container(
                height: 85.h,
                width: 85.w,
                margin: EdgeInsets.only(right: 30.w),
                decoration: BoxDecoration(
                  color: context.palette.conductTile,
                  borderRadius: BorderRadius.circular(AppRadii.md.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('POINTS', style: white),
                    Text('${duty.points}',
                        style: text.displayMedium
                            ?.copyWith(color: AppColors.white)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '${formatTime(duty.start)} - ${formatTime(duty.end)}'
                      '\n(Next day)',
                      maxLines: 2,
                      style: text.titleSmall,
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    AutoSizeText(formatDay(duty.day),
                        maxLines: 1,
                        style: text.displayMedium
                            ?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              if (participating case final on?)
                Icon(
                  on ? Icons.check_rounded : Icons.close_rounded,
                  key: Key('${on ? 'onDuty' : 'offDuty'}-${duty.id}'),
                  color: on ? context.colors.tertiary : context.palette.muted,
                  size: 35.sp,
                ),
            ],
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Participants', style: text.displayMedium),
            ),
            SizedBox(
              height: 220.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final MapEntry(key: name, value: rank)
                      in duty.participants.entries)
                    SoldierCard(name: name, rank: rank),
                ],
              ),
            ),
            if (onEdit != null) ...[
              PrimaryButton(
                key: Key('editDuty-${duty.id}'),
                label: 'EDIT DUTY',
                icon: Icons.edit_document,
                style: PrimaryButtonStyle.brand,
                onPressed: onEdit,
              ),
              gap,
            ],
            if (onDelete != null) ...[
              PrimaryButton(
                key: Key('deleteDuty-${duty.id}'),
                label: 'DELETE DUTY',
                icon: Icons.delete_forever,
                style: PrimaryButtonStyle.danger,
                onPressed: onDelete,
              ),
              gap,
            ],
          ],
        ),
      ),
    );
  }
}

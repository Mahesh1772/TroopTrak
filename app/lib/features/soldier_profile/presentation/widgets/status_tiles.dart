import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/constants/status_types.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../statuses/domain/entities/status.dart';

IconData statusIcon(String type) => switch (type) {
      StatusTypes.leave => Icons.medical_services_rounded,
      StatusTypes.medicalAppointment => Icons.date_range_rounded,
      _ => Icons.personal_injury_rounded,
    };

Color statusColor(AppPalette palette, String type) => switch (type) {
      StatusTypes.leave => palette.statusLeave,
      StatusTypes.medicalAppointment => palette.statusMedical,
      _ => palette.statusExcuse,
    };

String statusPeriod(Status s) => '${formatDay(s.start)} - ${formatDay(s.end)}';

/// Rebuild of `current_status_detailed_screen_tile.dart`.
class ActiveStatusCard extends StatelessWidget {
  const ActiveStatusCard({
    super.key,
    required this.status,
    this.onTap,
    this.onDelete,
  });

  final Status status;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final white = text.titleSmall?.copyWith(color: AppColors.white);
    return Padding(
      padding: EdgeInsets.all(15.sp),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg.r),
        child: Container(
          width: 230.w,
          padding: EdgeInsets.all(AppSpacing.md.sp),
          decoration: BoxDecoration(
            color: statusColor(context.palette, status.type),
            borderRadius: BorderRadius.circular(AppRadii.lg.r),
            boxShadow: AppShadows.tile,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(statusIcon(status.type),
                      color: AppColors.white, size: 60.sp),
                  if (onDelete != null)
                    IconButton(
                      key: Key('deleteStatus-${status.id}'),
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_rounded,
                          color: AppColors.white, size: 30.sp),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.xs.h),
              AutoSizeText(status.name,
                  maxLines: 2,
                  style: text.displaySmall?.copyWith(color: AppColors.white)),
              Text(status.type.toUpperCase(), style: white),
              Text(statusPeriod(status),
                  style: white?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rebuild of `past_status_detailed_screen_tile.dart`; slide for edit/delete.
class PastStatusTile extends StatelessWidget {
  const PastStatusTile({
    super.key,
    required this.status,
    this.onEdit,
    this.onDelete,
  });

  final Status status;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final radius = Radius.circular(AppRadii.lg.r);
    final manageable = onEdit != null || onDelete != null;
    final tile = Container(
      decoration: BoxDecoration(
        color: context.palette.pastTile,
        borderRadius: manageable
            ? BorderRadius.horizontal(left: radius)
            : BorderRadius.all(radius),
      ),
      padding: EdgeInsets.all(AppSpacing.lg.sp),
      child: Row(
        children: [
          Icon(statusIcon(status.type), color: AppColors.white, size: 30.sp),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: AutoSizeText(status.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.headlineMedium?.copyWith(color: AppColors.white)),
          ),
          SizedBox(width: AppSpacing.sm.w),
          AutoSizeText(statusPeriod(status),
              maxLines: 1,
              style: text.headlineSmall?.copyWith(color: AppColors.white)),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: !manageable
          ? tile
          : Slidable(
              key: Key('pastStatus-${status.id}'),
              endActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  if (onEdit != null)
                    SlidableAction(
                      key: Key('editStatus-${status.id}'),
                      onPressed: (_) => onEdit!(),
                      icon: Icons.info_rounded,
                      backgroundColor: AppColors.info,
                      foregroundColor: AppColors.white,
                    ),
                  if (onDelete != null)
                    SlidableAction(
                      key: Key('deletePastStatus-${status.id}'),
                      onPressed: (_) => onDelete!(),
                      icon: Icons.delete_forever_rounded,
                      backgroundColor: AppColors.danger,
                      foregroundColor: AppColors.white,
                      borderRadius: BorderRadius.horizontal(right: radius),
                    ),
                ],
              ),
              child: tile,
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/status_types.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/icon_plate.dart';
import '../../../../core/widgets/slidable_row.dart';
import '../../../../core/widgets/state_tone.dart';
import '../../../statuses/domain/entities/status.dart';

IconData statusIcon(String type) => switch (type) {
      StatusTypes.leave => Icons.flight_takeoff_rounded,
      StatusTypes.medicalAppointment => Icons.medical_services_rounded,
      _ => Icons.assignment_late_rounded,
    };

String statusPeriod(Status s) => '${formatDay(s.start)} - ${formatDay(s.end)}';

/// A running status: a gradient by type, with [daysLeft] as a badge.
class ActiveStatusCard extends StatelessWidget {
  const ActiveStatusCard({
    super.key,
    required this.status,
    required this.daysLeft,
    this.onTap,
    this.onDelete,
  });

  final Status status;
  final String daysLeft;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final onDelete = this.onDelete;
    return SizedBox(
      width: AppLayout.statusCardWidth.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl.r),
        child: Material(
          type: MaterialType.transparency,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: status.tone.gradient(palette),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg.w,
                      AppSpacing.control.h,
                      AppSpacing.lg.w,
                      AppSpacing.lg.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon(status.type),
                          color: AppColors.white,
                          size: AppLayout.statusCardIcon.r,
                        ),
                        SizedBox(height: AppLayout.statusCardNameTop.h),
                        Text(
                          status.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle(AppColors.white),
                        ),
                        Text(
                          status.type.toUpperCase(),
                          style: AppTextStyles.overline(
                              AppColors.onGradientSubtitle),
                        ),
                        SizedBox(height: AppSpacing.xxs.h),
                        Text(
                          statusPeriod(status),
                          style: AppTextStyles.figure(
                            15,
                            FontWeight.w500,
                            AppColors.onGradientSubtitle,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md.h),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.onGradientBadge,
                            borderRadius: BorderRadius.circular(AppRadii.md.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm.w,
                              vertical: AppLayout.badgeVertical.h,
                            ),
                            child: Text(
                              daysLeft,
                              style: AppTextStyles.badge(AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    Positioned(
                      top: AppLayout.statusCardDeleteInset.h,
                      right: AppLayout.statusCardDeleteInset.w,
                      child: IconButton(
                        key: Key('deleteStatus-${status.id}'),
                        onPressed: onDelete,
                        style: IconButton.styleFrom(
                          fixedSize: Size.square(AppLayout.statusCardDelete.r),
                        ),
                        icon: Icon(
                          Icons.delete_rounded,
                          color: AppColors.white,
                          size: AppLayout.statusCardIcon.r,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A finished status: a type-icon plate, the name and "TYPE · period". Slides
/// for edit and delete when the callbacks are given.
class PastStatusRow extends StatelessWidget {
  const PastStatusRow({
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
    final palette = context.palette;
    final manageable = onEdit != null || onDelete != null;
    return SlidableRow(
      key: Key('pastStatus-${status.id}'),
      onEdit: onEdit,
      onDelete: onDelete,
      editKey: Key('editStatus-${status.id}'),
      deleteKey: Key('deletePastStatus-${status.id}'),
      child: AppListRow(
        title: status.name,
        leading: IconPlate(statusIcon(status.type), tone: status.tone),
        subtitle: Text(
          '${status.type.toUpperCase()} · ${statusPeriod(status)}',
          style: AppTextStyles.figure(
            14.5,
            FontWeight.w500,
            palette.secondaryText,
          ),
        ),
        trailing: manageable
            ? Icon(
                Icons.chevron_left_rounded,
                size: AppLayout.iconPlateIcon.r,
                color: palette.mutedText,
              )
            : null,
      ),
    );
  }
}

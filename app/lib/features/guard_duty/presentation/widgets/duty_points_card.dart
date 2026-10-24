import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/number_formats.dart';

const _overlineSize = 13.0;
const _overlineTracking = 0.08;
const _figureSize = 52.0;
const _padX = 18.0;

/// The expected points per person on the header gradient, with the day rule
/// that sets them.
class DutyPointsCard extends StatelessWidget {
  const DutyPointsCard(
      {super.key, required this.points, required this.dayType});

  final double points;
  final String dayType;

  @override
  Widget build(BuildContext context) {
    final overline = AppTextStyles.barlow(
      _overlineSize,
      FontWeight.w700,
      AppColors.onGradientLabel,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.palette.headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _padX.w,
          vertical: AppSpacing.lg.h,
        ),
        child: Row(
          spacing: AppSpacing.lg.w,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs.h,
                children: [
                  Text(
                    'EXPECTED POINTS PER PERSON',
                    style: overline.copyWith(
                      letterSpacing: _overlineSize * _overlineTracking,
                    ),
                  ),
                  Text(
                    dayType,
                    key: const Key('dayType'),
                    style: AppTextStyles.h2(AppColors.onGradientGreeting)
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Text(
              formatPoints(points),
              key: const Key('expectedPoints'),
              maxLines: 1,
              style: AppTextStyles.figure(
                _figureSize,
                FontWeight.w700,
                AppColors.white,
              ).copyWith(height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

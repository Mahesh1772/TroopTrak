import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../domain/entities/conduct.dart';

/// Rebuild of `conduct_main_page_tiles.dart`.
class ConductTile extends StatelessWidget {
  const ConductTile({
    super.key,
    required this.conduct,
    required this.number,
    required this.onTap,
  });

  final Conduct conduct;
  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return InkWell(
      key: Key('conduct-${conduct.id}'),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.sp),
        child: Row(
          children: [
            Container(
              height: 70.h,
              width: 70.w,
              margin: EdgeInsets.only(right: 30.w),
              decoration: BoxDecoration(
                color: context.palette.conductTile,
                borderRadius: BorderRadius.circular(AppRadii.md.r),
              ),
              alignment: Alignment.center,
              child: Text('$number',
                  style: text.displayMedium?.copyWith(color: AppColors.white)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(conduct.type,
                      maxLines: 1, style: text.titleSmall),
                  AutoSizeText(conduct.name,
                      maxLines: 1,
                      style: text.displayMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
              child: const Icon(Icons.arrow_forward_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

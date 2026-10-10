import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

class ExpandableCountTile extends StatelessWidget {
  const ExpandableCountTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.leading,
    required this.children,
    this.childrenHeight = 220,
    this.emptyMessage = 'No personnel',
  });

  final String title;
  final String subtitle;
  final String count;
  final Widget leading;
  final List<Widget> children;
  final double childrenHeight;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.lg.h),
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        border: Border.all(width: 2.w, color: AppColors.tileBorder),
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
              SizedBox(height: 20.h, width: 20.w, child: leading),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleLarge),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleSmall?.copyWith(
                            color:
                                text.bodyMedium?.color?.withValues(alpha: 0.45),
                          )),
                    ],
                  ),
                ),
              ),
              Text(count,
                  style: text.displayMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
          children: [
            SizedBox(
              height: childrenHeight.h,
              child: children.isEmpty
                  ? Center(child: Text(emptyMessage, style: text.bodySmall))
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.all(AppRadii.lg.r),
                      children: children,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

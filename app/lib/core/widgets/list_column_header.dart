import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';

/// The two column titles above the rows of an [AppListCard], such as
/// SOLDIER and BOOKED IN.
class ListColumnHeader extends StatelessWidget {
  const ListColumnHeader({super.key, required this.start, required this.end});

  final String start;
  final String end;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.columnHeader(context.palette.secondaryText);
    return SizedBox(
      height: AppLayout.columnHeaderHeight.h,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.control.w,
          AppSpacing.xs.h,
          AppSpacing.control.w,
          0,
        ),
        child: Row(
          children: [
            Expanded(child: Text(start, maxLines: 1, style: style)),
            Text(end, maxLines: 1, style: style),
          ],
        ),
      ),
    );
  }
}

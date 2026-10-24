import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../domain/services/roster_filter.dart';

/// "Search mode" caption over one scrolling row of single-select chips.
class SearchModeChips extends StatelessWidget {
  const SearchModeChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final SearchCategory selected;
  final ValueChanged<SearchCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl.w,
            AppSpacing.control.h,
            AppSpacing.xl.w,
            AppSpacing.sm.h,
          ),
          child: Text(
            'Search mode',
            style: AppTextStyles.caption(context.palette.secondaryText),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
          child: Row(
            spacing: AppSpacing.sm.w,
            children: [
              for (final category in SearchCategory.values)
                ChoiceChip(
                  key: Key('chip-${category.name}'),
                  label: Text(category.label),
                  selected: selected == category,
                  onSelected: (_) => onSelected(category),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

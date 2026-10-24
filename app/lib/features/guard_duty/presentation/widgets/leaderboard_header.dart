import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../providers/leaderboard_provider.dart';

const _labels = {
  LeaderboardColumn.rank: 'RANK',
  LeaderboardColumn.name: 'NAME',
  LeaderboardColumn.points: 'POINTS',
};

/// RANK / NAME / POINTS titles above the rows; each sorts its column, and the
/// sorted one shows an arrow for the direction. Keys `sort-<column>`.
class LeaderboardHeader extends StatelessWidget {
  const LeaderboardHeader({
    super.key,
    required this.column,
    required this.ascending,
    required this.onSort,
  });

  final LeaderboardColumn column;
  final bool ascending;
  final ValueChanged<LeaderboardColumn> onSort;

  Widget _title(LeaderboardColumn c, Alignment alignment) => _SortTitle(
        column: c,
        alignment: alignment,
        selected: c == column,
        ascending: ascending,
        onTap: () => onSort(c),
      );

  @override
  Widget build(BuildContext context) => SizedBox(
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
              SizedBox(
                width: (AppLayout.leaderboardRankColumn + AppSpacing.md).w,
                child: _title(LeaderboardColumn.rank, Alignment.centerLeft),
              ),
              Expanded(
                  child: _title(LeaderboardColumn.name, Alignment.centerLeft)),
              SizedBox(
                width: AppLayout.leaderboardPointsColumn.w,
                child: _title(LeaderboardColumn.points, Alignment.centerRight),
              ),
            ],
          ),
        ),
      );
}

class _SortTitle extends StatelessWidget {
  const _SortTitle({
    required this.column,
    required this.alignment,
    required this.selected,
    required this.ascending,
    required this.onTap,
  });

  final LeaderboardColumn column;
  final Alignment alignment;
  final bool selected;
  final bool ascending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = selected ? palette.onCard : palette.secondaryText;
    return InkWell(
      key: Key('sort-${column.name}'),
      onTap: onTap,
      child: Align(
        alignment: alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xxs.w,
          children: [
            Text(
              _labels[column]!,
              maxLines: 1,
              style: AppTextStyles.columnHeader(color),
            ),
            if (selected)
              Icon(
                ascending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: AppLayout.sortArrow.r,
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}

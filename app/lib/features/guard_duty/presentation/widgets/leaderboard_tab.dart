import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../providers/leaderboard_provider.dart';
import 'leaderboard_header.dart';
import 'leaderboard_row.dart';

/// Rebuild of `tabs/points_leaderboard.dart` (D8: no Syncfusion grid).
class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        AppSpacing.lg.h,
        AppSpacing.lg.w,
        AppLayout.listFabClearance.h,
      ),
      children: [
        SectionHeader(
          'Points Leaderboard',
          padding: EdgeInsets.only(bottom: AppLayout.sectionBottom.h),
        ),
        AppSearchField(
          key: const Key('leaderboardSearch'),
          hintText: 'Search Name',
          onChanged: provider.search,
        ),
        SizedBox(height: AppSpacing.md.h),
        StateView<List<Soldier>>(
          state: provider.state,
          builder: (context, _) => AppListCard(
            key: const Key('leaderboard'),
            dividerInset: 0,
            header: LeaderboardHeader(
              column: provider.column,
              ascending: provider.ascending,
              onSort: provider.sortBy,
            ),
            children: [
              for (final soldier in provider.rows!)
                LeaderboardRow(
                  key: ValueKey('row-${soldier.id}'),
                  soldier: soldier,
                  fraction: provider.barFraction(soldier),
                  isSelf: provider.isSelf(soldier),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

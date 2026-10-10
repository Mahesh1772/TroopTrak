import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/rank_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/rank_avatar.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../providers/leaderboard_provider.dart';

/// Rebuild of `tabs/points_leaderboard.dart` (D8: DataTable, no Syncfusion).
class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();
    final text = context.textStyles;
    final header = text.headlineLarge
        ?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600);
    DataColumn column(String label, LeaderboardColumn c,
            {bool numeric = false}) =>
        DataColumn(
          numeric: numeric,
          label: Text(label, key: Key('sort-${c.name}'), style: header),
          onSort: (_, __) => provider.sortBy(c),
        );

    return ListView(
      padding: EdgeInsets.only(top: AppSpacing.xl.h, bottom: 30.h),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.lg.sp),
              decoration: BoxDecoration(
                boxShadow: AppShadows.tile,
                gradient:
                    LinearGradient(colors: context.palette.headerGradient),
                borderRadius: BorderRadius.circular(AppRadii.md.r),
              ),
              child:
                  const Icon(Icons.leaderboard_rounded, color: AppColors.white),
            ),
            SizedBox(width: AppSpacing.xl.w),
            Flexible(
              child: AutoSizeText('Points Leaderboard',
                  maxLines: 1, style: text.displayMedium),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.xl.sp),
          child: AppSearchField(
            key: const Key('leaderboardSearch'),
            hintText: 'Search Name',
            onChanged: provider.search,
          ),
        ),
        StateView<List<Soldier>>(
          state: provider.state,
          builder: (context, _) => DataTable(
            key: const Key('leaderboard'),
            sortColumnIndex: provider.column.index,
            sortAscending: provider.ascending,
            headingRowColor:
                const WidgetStatePropertyAll(AppColors.navActiveEnd),
            dataRowMinHeight: 70.h,
            dataRowMaxHeight: 100.h,
            columnSpacing: AppSpacing.lg.w,
            columns: [
              column('Rank', LeaderboardColumn.rank),
              column('Name', LeaderboardColumn.name),
              column('Points', LeaderboardColumn.points, numeric: true),
            ],
            rows: [
              for (final s in provider.rows!)
                DataRow(
                  key: ValueKey('row-${s.id}'),
                  cells: [
                    DataCell(Center(
                      child: RankAvatar.insignia(
                        s.rank,
                        size: 35.w,
                        tint: false,
                        color: RankAssets.tintInsignia(s.rank)
                            ? AppColors.warning
                            : null,
                      ),
                    )),
                    DataCell(Text(s.name, style: text.bodyMedium)),
                    DataCell(Text('${s.points}', style: text.bodyMedium)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/services/roster_filter.dart';
import '../providers/nominal_roll_provider.dart';
import '../widgets/soldier_tile.dart';

/// Rebuild of `CMD/screens/nominal_roll_screen/nominal_roll_screen_new.dart`.
class NominalRollPage extends StatelessWidget {
  const NominalRollPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NominalRollProvider>();
    final text = context.textStyles;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        key: const Key('scanQr'),
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.qrScanner),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.xl.sp),
              child: AppSearchField(
                key: const Key('rosterSearch'),
                onChanged: provider.search,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
              child: Text('Search Mode: ',
                  style: text.displaySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colors.tertiary)),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(AppSpacing.sm.sp),
              child: Row(
                children: [
                  for (final c in SearchCategory.values)
                    Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm.w),
                      child: ChoiceChip(
                        key: Key('chip-${c.name}'),
                        label: Text(c.label),
                        selected: provider.category == c,
                        onSelected: (_) => provider.selectCategory(c),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: StateView<List<Soldier>>(
                state: provider.state,
                builder: (context, _) {
                  final soldiers = provider.visible!;
                  if (soldiers.isEmpty && provider.query.isNotEmpty) {
                    return Center(
                      child: Text('No results Found!',
                          textAlign: TextAlign.center,
                          style: text.displayLarge?.copyWith(
                              fontSize: 45.sp,
                              fontWeight: FontWeight.normal,
                              color: AppColors.authLink)),
                    );
                  }
                  return GridView.builder(
                    padding: EdgeInsets.all(AppSpacing.md.sp),
                    itemCount: soldiers.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.w / 1.5.h,
                    ),
                    itemBuilder: (context, i) {
                      final soldier = soldiers[i];
                      return SoldierTile(
                        soldier: soldier,
                        onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.soldierProfile,
                            arguments: soldier.id),
                        onToggle: (inCamp) async {
                          final error =
                              await provider.setInCamp(soldier, inCamp);
                          if (!context.mounted) return;
                          AppSnackbar.outcome(context, error,
                              success: '${soldier.name} booked '
                                  '${inCamp ? 'in' : 'out'}');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

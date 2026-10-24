import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/list_column_header.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../statuses/domain/services/parade_roster.dart';
import '../../domain/entities/nominal_roll.dart';
import '../providers/nominal_roll_provider.dart';
import '../widgets/booked_in_tally.dart';
import '../widgets/search_mode_chips.dart';
import '../widgets/soldier_tile.dart';

/// Rebuild of `CMD/screens/nominal_roll_screen/nominal_roll_screen_new.dart`.
class NominalRollPage extends StatelessWidget {
  const NominalRollPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NominalRollProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        key: const Key('scanQr'),
        heroTag: null,
        tooltip: 'Scan enlistment QR',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.qrScanner),
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: AppLayout.listFabClearance.h),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg.w,
              AppSpacing.xs.h,
              AppSpacing.lg.w,
              0,
            ),
            child: AppSearchField(
              key: const Key('rosterSearch'),
              hintText: 'Search ${provider.category.label}',
              onChanged: provider.search,
            ),
          ),
          SearchModeChips(
            selected: provider.category,
            onSelected: provider.selectCategory,
          ),
          StateView<NominalRoll>(
            state: provider.state,
            builder: (context, roll) => _RollBody(
              roll: roll,
              visible: provider.visible,
              searching: provider.query.isNotEmpty,
            ),
          ),
        ],
      ),
    );
  }
}

class _RollBody extends StatelessWidget {
  const _RollBody({
    required this.roll,
    required this.visible,
    required this.searching,
  });

  final NominalRoll roll;
  final List<ParadeEntry> visible;
  final bool searching;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NominalRollProvider>();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        AppSpacing.lg.h,
        AppSpacing.lg.w,
        0,
      ),
      child: Column(
        spacing: AppSpacing.md.h,
        children: [
          BookedInTally(roll: roll),
          if (visible.isEmpty)
            EmptyState(
              message: searching ? 'No results Found!' : 'No soldiers yet',
              icon: searching
                  ? Icons.person_search_rounded
                  : Icons.groups_rounded,
            )
          else
            AppListCard(
              header: const ListColumnHeader(
                start: 'SOLDIER',
                end: 'BOOKED IN',
              ),
              children: [
                for (final entry in visible)
                  SoldierTile(
                    entry: entry,
                    onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.soldierProfile,
                        arguments: entry.soldier.id),
                    onToggle: (inCamp) async {
                      final error =
                          await provider.setInCamp(entry.soldier.id, inCamp);
                      if (!context.mounted) return;
                      AppSnackbar.outcome(context, error,
                          success: '${entry.soldier.name} booked '
                              '${inCamp ? 'in' : 'out'}');
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/soldier_row.dart';
import '../../../../core/widgets/state_view.dart';
import '../../domain/entities/conduct.dart';
import '../../domain/usecases/watch_conduct_breakdown.dart';
import '../providers/conduct_details_provider.dart';
import '../widgets/conduct_details_header.dart';

/// Rebuild of `CMD/.../conduct_details_screen.dart`. Edit and delete only
/// when [canManage]; the source deleted without asking.
class ConductDetailsPage extends StatelessWidget {
  const ConductDetailsPage({super.key, this.canManage = true});

  final bool canManage;

  Future<void> _delete(BuildContext context, Conduct conduct) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete ${conduct.name}?',
      message: 'This removes the conduct and its participant list.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final navigator = Navigator.of(context);
    final error = await context.read<ConductDetailsProvider>().delete();
    if (context.mounted) {
      AppSnackbar.outcome(context, error, success: '${conduct.name} deleted');
    }
    if (error == null) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConductDetailsProvider>();
    return Scaffold(
      body: StateView<ConductBreakdown>(
        state: provider.state,
        builder: (context, all) {
          final visible = provider.visible!;
          return ListView(
            padding: EdgeInsets.only(bottom: AppSpacing.xl.h),
            children: [
              ConductDetailsHeader(
                breakdown: all,
                onEdit: canManage
                    ? () => Navigator.of(context).pushNamed(
                          AppRoutes.editConduct,
                          arguments: all.conduct,
                        )
                    : null,
                onDelete:
                    canManage ? () => _delete(context, all.conduct) : null,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg.w,
                  AppSpacing.lg.h,
                  AppSpacing.lg.w,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.md.h,
                  children: [
                    AppSearchField(
                      key: const Key('detailsSearch'),
                      hintText: 'Search Name',
                      onChanged: provider.search,
                    ),
                    AppSegmentedControl<ConductGroup>(
                      selected: provider.group,
                      onChanged: provider.select,
                      segments: [
                        AppSegment(
                          value: ConductGroup.participants,
                          label: 'Participants',
                          count: visible.participants.length,
                        ),
                        AppSegment(
                          value: ConductGroup.nonParticipants,
                          label: 'Non-Participants',
                          count: visible.nonParticipants.length,
                        ),
                      ],
                    ),
                    if (provider.rows.isEmpty)
                      const EmptyState(message: 'Nothing to see here...yet.')
                    else
                      AppListCard(
                        children: [
                          for (final s in provider.rows)
                            SoldierRow(
                              soldier: s,
                              note: visible.noteFor(s),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

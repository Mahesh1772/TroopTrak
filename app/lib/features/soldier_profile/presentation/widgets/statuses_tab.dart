import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../statuses/domain/entities/status.dart';
import '../pages/status_form_page.dart';
import '../providers/statuses_provider.dart';
import 'status_tiles.dart';

/// Active status cards, past status rows and the add button. Read-only when
/// [canManage] is false.
class StatusesTab extends StatelessWidget {
  const StatusesTab(
      {super.key, required this.soldier, required this.canManage});

  final Soldier soldier;
  final bool canManage;

  Future<void> _open(BuildContext context, [Status? s]) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => StatusFormPage(soldier: soldier, status: s),
      ));

  Future<void> _delete(BuildContext context, Status status) async {
    final error = await context.read<StatusesProvider>().delete(status);
    if (!context.mounted) return;
    AppSnackbar.outcome(context, error, success: 'Status deleted');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatusesProvider>();
    final palette = context.palette;
    return StateView<List<Status>>(
      state: provider.state,
      builder: (context, _) {
        final split = provider.split!;
        final sides = EdgeInsets.symmetric(horizontal: AppSpacing.lg.w);
        return ListView(
          padding: EdgeInsets.only(bottom: AppSpacing.xxxl.h),
          children: [
            SectionHeader('Active Statuses', caption: '${split.active.length}'),
            if (split.active.isEmpty)
              const EmptyState(message: 'No active statuses')
            else
              SingleChildScrollView(
                key: const Key('activeStatuses'),
                scrollDirection: Axis.horizontal,
                padding: sides,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.md.w,
                    children: [
                      for (final s in split.active)
                        ActiveStatusCard(
                          key: Key('activeStatus-${s.id}'),
                          status: s,
                          daysLeft: provider.daysLeftLabel(s),
                          onTap: canManage ? () => _open(context, s) : null,
                          onDelete:
                              canManage ? () => _delete(context, s) : null,
                        ),
                    ],
                  ),
                ),
              ),
            SectionHeader('Past Statuses', caption: '${split.past.length}'),
            if (split.past.isEmpty)
              const EmptyState(message: 'No past statuses')
            else
              Padding(
                padding: sides,
                child: AppListCard(
                  children: [
                    for (final s in split.past)
                      PastStatusRow(
                        status: s,
                        onEdit: canManage ? () => _open(context, s) : null,
                        onDelete: canManage ? () => _delete(context, s) : null,
                      ),
                  ],
                ),
              ),
            if (canManage)
              Padding(
                padding: sides,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (split.past.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xs.w,
                          AppSpacing.sm.h,
                          AppSpacing.xs.w,
                          0,
                        ),
                        child: Text(
                          'Slide a row left to edit or delete',
                          style: AppTextStyles.caption(palette.secondaryText),
                        ),
                      ),
                    SizedBox(height: AppSpacing.lg.h),
                    PrimaryButton(
                      key: const Key('addStatus'),
                      label: 'ADD NEW STATUS',
                      icon: Icons.add_rounded,
                      onPressed: () => _open(context),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

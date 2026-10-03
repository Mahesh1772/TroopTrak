import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../statuses/domain/entities/status.dart';
import '../pages/status_form_page.dart';
import '../providers/statuses_provider.dart';
import 'status_tiles.dart';

/// Rebuild of `statuses_detailed_screen_tab.dart`: active cards (R2), past
/// list, add button. Read-only when [canManage] is false.
class StatusesTab extends StatelessWidget {
  const StatusesTab({super.key, required this.canManage});

  final bool canManage;

  Future<void> _open(BuildContext context, String soldierId, [Status? s]) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => StatusFormPage(soldierId: soldierId, status: s),
      ));

  Future<void> _delete(BuildContext context, Status status) async {
    final error = await context.read<StatusesProvider>().delete(status);
    if (error != null && context.mounted) AppSnackbar.error(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatusesProvider>();
    return StateView<List<Status>>(
      state: provider.state,
      builder: (context, _) {
        final split = provider.split!;
        final id = provider.soldierId;
        final headerPadding =
            EdgeInsets.symmetric(horizontal: 30.w, vertical: AppSpacing.sm.h);
        return ListView(
          padding: EdgeInsets.only(bottom: AppSpacing.xxxl.h),
          children: [
            SectionHeader('Active Statuses',
                icon: Icons.medical_information_rounded,
                padding: headerPadding),
            SizedBox(
              height: 260.h,
              child: ListView(
                key: const Key('activeStatuses'),
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
                children: [
                  for (final s in split.active)
                    ActiveStatusCard(
                      key: Key('activeStatus-${s.id}'),
                      status: s,
                      onTap: canManage ? () => _open(context, id, s) : null,
                      onDelete: canManage ? () => _delete(context, s) : null,
                    ),
                ],
              ),
            ),
            SectionHeader('Past Statuses',
                icon: Icons.av_timer_rounded, padding: headerPadding),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                children: [
                  for (final s in split.past)
                    PastStatusTile(
                      status: s,
                      onEdit: canManage ? () => _open(context, id, s) : null,
                      onDelete: canManage ? () => _delete(context, s) : null,
                    ),
                ],
              ),
            ),
            if (canManage) ...[
              SizedBox(height: AppSpacing.xl.h),
              Center(
                child: PrimaryButton(
                  key: const Key('addStatus'),
                  label: 'ADD NEW STATUS',
                  icon: Icons.note_add,
                  style: PrimaryButtonStyle.brand,
                  pill: true,
                  expand: false,
                  onPressed: () => _open(context, id),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

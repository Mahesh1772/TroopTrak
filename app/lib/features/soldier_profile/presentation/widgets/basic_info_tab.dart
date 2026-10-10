import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../profile_actions.dart';
import '../profile_capabilities.dart';

/// Rebuild of `basic_info_detailed_screen_tab.dart` (the source's five rows).
class BasicInfoTab extends StatefulWidget {
  const BasicInfoTab({
    super.key,
    required this.soldier,
    required this.capabilities,
    required this.actions,
  });

  final Soldier soldier;
  final ProfileCapabilities capabilities;
  final ProfileActions actions;

  @override
  State<BasicInfoTab> createState() => _BasicInfoTabState();
}

class _BasicInfoTabState extends State<BasicInfoTab> {
  bool _deleting = false;

  static String _day(DateTime? date) =>
      date == null ? '-' : formatDay(date).toUpperCase();

  Future<void> _delete(ProfileActions actions) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete ${widget.soldier.name}?',
      message: actions.deleteMessage,
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _deleting = true);
    final result = await actions.delete!(widget.soldier);
    result.fold(
      (f) {
        if (!mounted) return;
        setState(() => _deleting = false);
        AppSnackbar.error(context, f.message);
      },
      (_) {
        AppSnackbar.showOn(
            messenger,
            actions.deletedMessage ?? '${widget.soldier.name} deleted',
            SnackKind.success);
        actions.afterDelete?.call(navigator);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.soldier;
    final caps = widget.capabilities;
    final actions = widget.actions;
    final gap = SizedBox(height: AppSpacing.xl.h);
    return ListView(
      padding: EdgeInsets.only(bottom: AppSpacing.xxxl.h),
      children: [
        InfoRow(
            icon: Icons.cake_rounded,
            title: 'Date Of Birth',
            content: _day(s.dob)),
        InfoRow(
            icon: Icons.food_bank_rounded,
            title: 'Ration Type:',
            content: s.rationType.toUpperCase()),
        InfoRow(
            icon: Icons.bloodtype_rounded,
            title: 'Blood Type:',
            content: s.bloodGroup),
        InfoRow(
            icon: Icons.date_range_rounded,
            title: 'Enlistment Date:',
            content: _day(s.enlistment)),
        InfoRow(
            icon: Icons.military_tech_rounded,
            title: 'ORD:',
            content: _day(s.ord)),
        SizedBox(height: 30.h),
        if (caps.canEdit) ...[
          Center(
            child: PrimaryButton(
              key: const Key('editSoldier'),
              label: 'EDIT SOLDIER DETAILS',
              icon: Icons.edit_document,
              style: PrimaryButtonStyle.brand,
              pill: true,
              expand: false,
              onPressed: () => actions.edit(context, s),
            ),
          ),
          gap,
        ],
        if (caps.canDelete && actions.delete != null)
          Center(
            child: PrimaryButton(
              key: const Key('deleteSoldier'),
              label: 'DELETE SOLDIER DETAILS',
              icon: Icons.delete,
              style: PrimaryButtonStyle.danger,
              pill: true,
              expand: false,
              loading: _deleting,
              onPressed: () => _delete(actions),
            ),
          ),
      ],
    );
  }
}

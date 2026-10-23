import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/definition_list.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../profile_actions.dart';
import '../profile_capabilities.dart';

/// Rebuild of `basic_info_detailed_screen_tab.dart`: the five source rows in a
/// definition list, then EDIT and DELETE for those who may.
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
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        AppSpacing.lg.h,
        AppSpacing.lg.w,
        AppSpacing.xxxl.h,
      ),
      children: [
        DefinitionList(entries: [
          ('Date Of Birth', formatDayCaps(s.dob)),
          ('Ration Type', s.rationLabel),
          ('Blood Type', s.bloodGroup),
          ('Enlistment Date', formatDayCaps(s.enlistment)),
          ('ORD', formatDayCaps(s.ord)),
        ]),
        if (caps.canEdit) ...[
          SizedBox(height: AppSpacing.md.h),
          PrimaryButton(
            key: const Key('editSoldier'),
            label: 'EDIT SOLDIER DETAILS',
            icon: Icons.edit_rounded,
            onPressed: () => actions.edit(context, s),
          ),
        ],
        if (caps.canDelete && actions.delete != null) ...[
          SizedBox(height: AppSpacing.md.h),
          PrimaryButton(
            key: const Key('deleteSoldier'),
            label: 'DELETE SOLDIER DETAILS',
            icon: Icons.delete_rounded,
            style: PrimaryButtonStyle.danger,
            loading: _deleting,
            onPressed: () => _delete(actions),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/ranks.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/profile_form_fields.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/usecases/soldier_usecases.dart';
import '../../../soldiers/domain/validators/soldier_validators.dart';

enum SoldierFormMode { add, edit }

/// Rebuild of `add_new_soldier_screen.dart`, `update_soldier_details_screen.dart`
/// and `update_current_user_details.dart`: one form for add, edit-other and
/// edit-self. The source update screens skipped validation; both modes
/// validate here.
class SoldierFormPage extends StatefulWidget {
  const SoldierFormPage({super.key, required this.mode, this.initial});

  final SoldierFormMode mode;

  /// Prefill: the scanned registration (add) or the soldier being edited.
  final Soldier? initial;

  @override
  State<SoldierFormPage> createState() => _SoldierFormPageState();
}

class _SoldierFormPageState extends State<SoldierFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final DateTime _today = context.read<Clock>().now();
  late final _profile = ProfileFormController(today: _today);
  bool _saving = false;

  bool get _isAdd => widget.mode == SoldierFormMode.add;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s != null) {
      _profile.prefill(
        name: s.name,
        rank: s.rank,
        company: s.company,
        platoon: s.platoon,
        section: s.section,
        appointment: s.appointment,
        rationType: s.rationType,
        bloodGroup: s.bloodGroup,
        dob: s.dob,
        enlistment: s.enlistment,
        ord: s.ord,
      );
    }
  }

  @override
  void dispose() {
    _profile.dispose();
    super.dispose();
  }

  Soldier _draft() {
    final p = _profile;
    final base = widget.initial;
    return Soldier(
      id: _isAdd ? '' : base!.id,
      name: p.name.text.trim(),
      rank: p.rank!,
      company: p.company.text.trim(),
      platoon: p.platoon.text.trim(),
      section: p.section.text.trim(),
      appointment: p.appointment.text.trim(),
      rationType: p.rationType!,
      bloodGroup: p.bloodGroup!,
      dob: p.dob,
      enlistment: p.enlistment,
      ord: p.ord,
      isInCamp: _isAdd || base!.isInCamp,
      points: _isAdd ? 0 : base!.points,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.error(context, 'Details missing');
      return;
    }
    setState(() => _saving = true);
    final draft = _draft();
    final result = await (_isAdd
        ? context.read<AddSoldier>()(draft)
        : context.read<UpdateSoldier>()(draft));
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (f) => AppSnackbar.error(context, f.message),
      (_) {
        final navigator = Navigator.of(context);
        if (_isAdd) {
          AppSnackbar.success(context, 'Soldier tile created');
          navigator.popUntil((route) => route.isFirst);
        } else {
          AppSnackbar.success(context, 'Soldier details updated');
          navigator.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isAdd ? "Let's get things set up  ✍️" : 'Change details  ✍️',
                  style: text.displayLarge?.copyWith(fontSize: 30.sp),
                ),
                Text(
                  _isAdd
                      ? 'Fill in the details of the new soldier you wish to add'
                      : 'Update the details of an existing soldier.',
                  style: text.bodySmall?.copyWith(fontWeight: FontWeight.w300),
                ),
                SizedBox(height: AppSpacing.lg.h),
                ProfileFormFields(
                  controller: _profile,
                  ranks: Ranks.all,
                  nameValidator: (v) => SoldierValidators.name(v?.trim()),
                  today: _today,
                ),
                SizedBox(height: AppSpacing.xxl.h),
                PrimaryButton(
                  key: const Key('saveSoldier'),
                  label: _isAdd ? 'ADD NEW SOLDIER' : 'UPDATE DETAILS',
                  icon: _isAdd
                      ? Icons.group_add_rounded
                      : Icons.edit_note_rounded,
                  loading: _saving,
                  onPressed: _submit,
                ),
                SizedBox(height: AppSpacing.xxl.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/ranks.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/dark_section.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/profile_form_fields.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/usecases/complete_soldier_profile.dart';
import '../../domain/validators/auth_validators.dart';

/// Rebuild of the source `get_user_info.dart` (R16).
class ProfileCapturePage extends StatefulWidget {
  const ProfileCapturePage({super.key});

  @override
  State<ProfileCapturePage> createState() => _ProfileCapturePageState();
}

class _ProfileCapturePageState extends State<ProfileCapturePage> {
  final _formKey = GlobalKey<FormState>();
  final _profile = ProfileFormController();
  late final DateTime _today = context.read<Clock>().now();
  bool _saving = false;

  @override
  void dispose() {
    _profile.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.error(context, CompleteSoldierProfile.detailsMissing);
      return;
    }
    final p = _profile;
    setState(() => _saving = true);
    final result = await context.read<CompleteSoldierProfile>()(Soldier(
      id: '',
      name: p.name.text,
      rank: p.rank ?? '',
      company: p.company.text.trim(),
      platoon: p.platoon.text.trim(),
      section: p.section.text.trim(),
      appointment: p.appointment.text.trim(),
      rationType: p.rationType ?? '',
      bloodGroup: p.bloodGroup ?? '',
      dob: p.dob,
      enlistment: p.enlistment,
      ord: p.ord,
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (f) => AppSnackbar.error(context, f.message),
      (_) {
        AppSnackbar.success(context, 'Soldier tile created');
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.soldierHome, (_) => false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return DarkSection(
      child: Scaffold(
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
                  Text("Let's get things set up  ✍️",
                      style: text.displayLarge?.copyWith(fontSize: 30.sp)),
                  Text('Fill in the details of the new soldier you wish to add',
                      style: text.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w300)),
                  SizedBox(height: AppSpacing.lg.h),
                  ProfileFormFields(
                    controller: _profile,
                    ranks: Ranks.soldierRegistration,
                    nameValidator: (v) => AuthValidators.soldierName(v?.trim()),
                    today: _today,
                  ),
                  SizedBox(height: AppSpacing.xxl.h),
                  PrimaryButton(
                    key: const Key('captureButton'),
                    label: 'ADD NEW SOLDIER',
                    icon: Icons.group_add_rounded,
                    loading: _saving,
                    onPressed: _submit,
                  ),
                  SizedBox(height: AppSpacing.xxl.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

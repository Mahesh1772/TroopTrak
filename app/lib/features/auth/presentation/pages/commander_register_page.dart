import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/ranks.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/form_page_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/profile_form_fields.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/usecases/register_commander.dart';
import '../../domain/validators/auth_validators.dart';
import '../providers/commander_auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/password_checklist.dart';

class CommanderRegisterPage extends StatefulWidget {
  const CommanderRegisterPage({super.key});

  @override
  State<CommanderRegisterPage> createState() => _CommanderRegisterPageState();
}

class _CommanderRegisterPageState extends State<CommanderRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late final DateTime _today = context.read<Clock>().now();
  late final _profile = ProfileFormController(today: _today);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _profile.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.error(context, 'Details missing');
      return;
    }
    final p = _profile;
    final error = await context.read<CommanderAuthProvider>().register(
          CommanderRegistration(
            email: _email.text,
            password: _password.text,
            profile: Soldier(
              id: '',
              name: p.name.text,
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
            ),
          ),
        );
    if (!mounted) return;
    error == null
        ? AppSnackbar.success(context, 'User Profile created')
        : AppSnackbar.error(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommanderAuthProvider>();
    return FormPageScaffold(
      formKey: _formKey,
      cta: PrimaryButton(
        key: const Key('registerButton'),
        label: 'Sign Up',
        loading: provider.loading,
        onPressed: _submit,
      ),
      children: [
        SizedBox(height: AppSpacing.xxl.h),
        const AuthHeader(
          title: 'Sign Up!',
          subtitle: 'Make your life easier, Register',
        ),
        SizedBox(height: AppSpacing.xxl.h),
        ProfileFormFields(
          controller: _profile,
          ranks: Ranks.commanderRegistration,
          nameValidator: AuthValidators.commanderName,
          today: _today,
        ),
        AppTextField(
          key: const Key('register-email'),
          controller: _email,
          label: 'Email:',
          hintText: 'Email@example.com',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: AuthValidators.email,
        ),
        AppTextField(
          key: const Key('register-password'),
          controller: _password,
          label: 'Enter password:',
          icon: Icons.lock_open_rounded,
          obscureText: true,
          validator: AuthValidators.newPassword,
        ),
        PasswordChecklist(controller: _password),
        AppTextField(
          key: const Key('register-confirm'),
          controller: _confirm,
          label: 'Confirm password:',
          icon: Icons.lock_rounded,
          obscureText: true,
          validator: (v) => AuthValidators.repeatedPassword(v, _password.text),
        ),
        AuthSwitchPrompt(
          prompt: 'Alr have an account?',
          action: 'Login here',
          actionKey: const Key('signInPageButton'),
          onTap: provider.toggleMode,
        ),
      ],
    );
  }
}

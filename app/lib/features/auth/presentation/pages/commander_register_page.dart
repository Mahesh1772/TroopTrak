import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/ranks.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/profile_form_fields.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/usecases/register_commander.dart';
import '../../domain/validators/auth_validators.dart';
import '../../domain/validators/password_rules.dart';
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

  static String? _name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'You must have a name right';
    if (AuthValidators.soldierName(v) == 'Name got number meh') {
      return 'Your name got number meh';
    }
    return null;
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
    final gap = SizedBox(height: AppSpacing.lg.h);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 30.h),
                const AuthHeader(
                  title: 'Sign Up!',
                  subtitle: 'Make your life easier, Register',
                ),
                SizedBox(height: 30.h),
                ProfileFormFields(
                  controller: _profile,
                  ranks: Ranks.commanderRegistration,
                  nameValidator: _name,
                  today: _today,
                ),
                gap,
                TextFormField(
                  key: const Key('register-email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.email,
                  decoration: const InputDecoration(
                    labelText: 'Email: (example - Email@example.com)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                gap,
                TextFormField(
                  key: const Key('register-password'),
                  controller: _password,
                  obscureText: true,
                  validator: (v) =>
                      AuthValidators.password(v) ??
                      (PasswordRule.isStrong(v!.trim())
                          ? null
                          : 'Password needs to be stronger'),
                  decoration: const InputDecoration(
                    labelText: 'Enter password:',
                    prefixIcon: Icon(Icons.lock_open),
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                PasswordChecklist(controller: _password),
                gap,
                TextFormField(
                  key: const Key('register-confirm'),
                  controller: _confirm,
                  obscureText: true,
                  validator: (v) => (v?.trim() ?? '') == _password.text.trim()
                      ? null
                      : 'Make sure both Passwords match',
                  decoration: const InputDecoration(
                    labelText: 'Confirm password:',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: AppSpacing.xxl.h),
                PrimaryButton(
                  key: const Key('registerButton'),
                  label: 'Sign Up',
                  loading: provider.loading,
                  onPressed: _submit,
                ),
                gap,
                AuthSwitchPrompt(
                  prompt: 'Alr have an account?',
                  action: 'Login here',
                  actionKey: const Key('signInPageButton'),
                  onTap: provider.toggleMode,
                ),
                gap,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

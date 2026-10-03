import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/validators/auth_validators.dart';
import '../providers/commander_auth_provider.dart';
import '../widgets/auth_header.dart';

class CommanderSignInPage extends StatefulWidget {
  const CommanderSignInPage({super.key});

  @override
  State<CommanderSignInPage> createState() => _CommanderSignInPageState();
}

class _CommanderSignInPageState extends State<CommanderSignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.error(context, 'Fill in all the fields');
      return;
    }
    final error = await context
        .read<CommanderAuthProvider>()
        .signIn(_email.text, _password.text);
    if (!mounted) return;
    error == null
        ? AppSnackbar.success(context, 'Login Successful')
        : AppSnackbar.error(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommanderAuthProvider>();
    final gap = SizedBox(height: AppSpacing.xl.h);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                SizedBox(height: 60.h),
                const AuthHeader(
                    title: 'Welcome to camp!', subtitle: 'Time to get back!'),
                SizedBox(height: 50.h),
                TextFormField(
                  key: const Key('email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.email,
                  decoration: const InputDecoration(
                    labelText: 'Email ID',
                    hintText: 'Email@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                gap,
                TextFormField(
                  key: const Key('password'),
                  controller: _password,
                  obscureText: true,
                  validator: AuthValidators.password,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter Password',
                    prefixIcon: Icon(Icons.lock_open),
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    key: const Key('forgotPasswordButton'),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.forgotPassword),
                    child: Text('Forgot Password? Aiyahhh',
                        style: context.textStyles.titleSmall
                            ?.copyWith(color: AppColors.authAccent)),
                  ),
                ),
                gap,
                PrimaryButton(
                  key: const Key('signInButton'),
                  label: 'Sign In',
                  loading: provider.loading,
                  onPressed: _submit,
                ),
                gap,
                AuthSwitchPrompt(
                  prompt: 'No account?',
                  action: 'Create one here!',
                  actionKey: const Key('registerPageButton'),
                  onTap: provider.toggleMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

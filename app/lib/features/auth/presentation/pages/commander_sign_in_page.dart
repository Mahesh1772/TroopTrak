import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/brand_plate.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/sticky_cta_page.dart';
import '../../domain/validators/auth_validators.dart';
import '../providers/commander_auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/link_prompt.dart';

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
    return StickyCtaPage(
      formKey: _formKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      cta: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            key: const Key('signInButton'),
            label: 'Sign In',
            loading: provider.loading,
            onPressed: _submit,
          ),
          LinkPrompt(
            prompt: 'No account?',
            action: 'Create one here!',
            actionKey: const Key('registerPageButton'),
            alignment: WrapAlignment.center,
            onTap: provider.toggleMode,
          ),
        ],
      ),
      children: [
        const AuthHeader(
          leading: BrandPlate(Icons.military_tech_rounded),
          title: 'Welcome to camp!',
          subtitle: 'Time to get back!',
        ),
        SizedBox(height: AppLayout.onboardingGap.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.md.h,
          children: [
            AppTextField(
              key: const Key('email'),
              controller: _email,
              label: 'Email ID',
              hintText: 'Email@example.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.email,
            ),
            AppTextField(
              key: const Key('password'),
              controller: _password,
              label: 'Password',
              hintText: 'Enter Password',
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              validator: AuthValidators.password,
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: LinkButton(
                key: const Key('forgotPasswordButton'),
                label: 'Forgot Password? Aiyahhh',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

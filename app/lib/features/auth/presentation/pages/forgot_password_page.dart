import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/page_back_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/sticky_cta_page.dart';
import '../providers/commander_auth_provider.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final error = await context
        .read<CommanderAuthProvider>()
        .sendPasswordReset(_email.text);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        content:
            Text(error ?? 'Reset link has been sent to your Email account!'),
      ),
    );
    if (error == null && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<CommanderAuthProvider>().loading;
    return StickyCtaPage(
      top: AppSpacing.md,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      cta: PrimaryButton(
        key: const Key('resetButton'),
        label: 'Reset Password',
        loading: loading,
        onPressed: _reset,
      ),
      children: [
        const PageBackButton(),
        SizedBox(height: AppSpacing.lg.h),
        const AuthHeader(
          title: 'Reset Password',
          subtitle: 'Enter in your Email, a reset link will be sent to it',
        ),
        SizedBox(height: AppSpacing.xxxl.h),
        AppTextField(
          key: const Key('reset-email'),
          controller: _email,
          label: 'Email ID',
          hintText: 'Email@example.com',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}

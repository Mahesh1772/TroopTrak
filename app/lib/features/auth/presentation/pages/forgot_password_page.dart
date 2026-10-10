import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/dark_section.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/commander_auth_provider.dart';

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
    return DarkSection(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter in your Email, a reset link will be sent to it',
                textAlign: TextAlign.center,
                style: context.textStyles.displaySmall
                    ?.copyWith(color: AppColors.authAccent),
              ),
              SizedBox(height: AppSpacing.xxl.h),
              TextField(
                key: const Key('reset-email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              SizedBox(height: AppSpacing.xxl.h),
              PrimaryButton(
                key: const Key('resetButton'),
                label: 'Reset Password',
                loading: loading,
                onPressed: _reset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

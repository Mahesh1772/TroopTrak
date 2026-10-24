import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/page_back_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/sticky_cta_bar.dart';
import '../../domain/validators/auth_validators.dart';
import '../providers/phone_auth_provider.dart';
import '../widgets/link_prompt.dart';
import '../widgets/otp_input.dart';
import 'phone_entry_page.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _code = TextEditingController();
  late final PhoneAuthProvider _provider = context.read<PhoneAuthProvider>();
  bool _rejected = false;

  @override
  void initState() {
    super.initState();
    _provider.addListener(_onAutoVerified);
  }

  @override
  void dispose() {
    _provider.removeListener(_onAutoVerified);
    _code.dispose();
    super.dispose();
  }

  void _onAutoVerified() {
    final outcome = _provider.takeAutoOutcome();
    if (outcome != null && mounted) {
      handlePhoneOutcome(context, outcome, _provider);
    }
  }

  Future<void> _verify() async {
    final outcome = await _provider.submitOtp(_code.text);
    if (!mounted) return;
    setState(() => _rejected = outcome == PhoneOutcome.failed);
    await handlePhoneOutcome(context, outcome, _provider);
  }

  Future<void> _resend() async {
    final outcome = await _provider.resend();
    if (!mounted) return;
    if (outcome == PhoneOutcome.failed) {
      AppSnackbar.error(context, _provider.error ?? 'Could not resend OTP.');
      return;
    }
    setState(() => _rejected = false);
    AppSnackbar.info(context, 'A new OTP has been sent.');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhoneAuthProvider>();
    final palette = context.palette;
    final number = provider.displayNumber;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xxl.w,
                  AppSpacing.md.h,
                  AppSpacing.xxl.w,
                  AppSpacing.lg.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageBackButton(),
                    SizedBox(height: AppSpacing.lg.h),
                    Text(
                      'User Verification',
                      style:
                          AppTextStyles.screenTitle(context.colors.onSurface),
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    Text.rich(
                      TextSpan(
                        text: 'Enter OTP Received.',
                        children: [
                          if (number != null) ...[
                            const TextSpan(text: ' We sent a 6-digit code to '),
                            TextSpan(
                              text: number,
                              style: AppTextStyles.figure(
                                17,
                                FontWeight.w700,
                                palette.onCard,
                              ),
                            ),
                          ],
                        ],
                      ),
                      style: AppTextStyles.screenSubtitle(
                        palette.secondaryText,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxxl.h),
                    OtpInput(
                      controller: _code,
                      invalid: _rejected,
                      enabled: !provider.busy,
                      onChanged: (_) {
                        if (_rejected) setState(() => _rejected = false);
                      },
                      onCompleted: (_) => _verify(),
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    LinkPrompt(
                      prompt: 'Did not receive OTP?',
                      action: 'Resend New OTP',
                      actionKey: const Key('resend'),
                      onTap: _resend,
                    ),
                  ],
                ),
              ),
            ),
            StickyCtaBar(
              horizontal: AppSpacing.xxl,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _code,
                builder: (_, value, __) => PrimaryButton(
                  key: const Key('verify'),
                  label: 'Verify',
                  loading: provider.busy,
                  onPressed:
                      AuthValidators.isOtpComplete(value.text) ? _verify : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

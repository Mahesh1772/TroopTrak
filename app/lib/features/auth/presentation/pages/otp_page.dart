import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/dark_section.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/validators/auth_validators.dart';
import '../providers/phone_auth_provider.dart';
import 'phone_entry_page.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _code = TextEditingController();
  late final PhoneAuthProvider _provider = context.read<PhoneAuthProvider>();

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
    final invalid = AuthValidators.otp(_code.text);
    if (invalid != null) {
      AppSnackbar.error(context, invalid);
      return;
    }
    final outcome = await _provider.submitOtp(_code.text);
    if (mounted) await handlePhoneOutcome(context, outcome, _provider);
  }

  Future<void> _resend() async {
    final outcome = await _provider.resend();
    if (!mounted) return;
    outcome == PhoneOutcome.failed
        ? AppSnackbar.error(context, _provider.error ?? 'Could not resend OTP.')
        : AppSnackbar.info(context, 'A new OTP has been sent.');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhoneAuthProvider>();
    final text = context.textStyles;
    final pinTheme = PinTheme(
      width: 56.w,
      height: 56.h,
      textStyle: text.displaySmall,
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(AppRadii.md.r),
        border: Border.all(color: AppColors.authIcon),
      ),
    );
    return DarkSection(
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: provider.busy
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    children: [
                      Image.asset(
                        'lib/assets/phone_auth/troopTrak_mascot.png',
                        height: 220.h,
                        color: AppColors.authIcon,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                      Text('User Verification',
                          style: text.displayMedium
                              ?.copyWith(color: AppColors.authLink)),
                      SizedBox(height: AppSpacing.sm.h),
                      Text('Enter OTP Recieved',
                          style: text.titleMedium
                              ?.copyWith(color: AppColors.authHint)),
                      SizedBox(height: AppSpacing.xxl.h),
                      Pinput(
                        key: const Key('otp'),
                        length: 6,
                        controller: _code,
                        defaultPinTheme: pinTheme,
                        onCompleted: (_) => _verify(),
                      ),
                      SizedBox(height: AppSpacing.xxxl.h),
                      PrimaryButton(
                        key: const Key('verify'),
                        label: 'Verify',
                        onPressed: _verify,
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                      Text('Did not recieve OTP?',
                          style: text.titleSmall
                              ?.copyWith(color: AppColors.authLink)),
                      TextButton(
                        key: const Key('resend'),
                        onPressed: _resend,
                        child: const Text('Resend New OTP'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

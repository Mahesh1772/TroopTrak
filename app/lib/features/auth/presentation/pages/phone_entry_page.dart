import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brand_mascot.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/sticky_cta_bar.dart';
import '../providers/phone_auth_provider.dart';
import '../widgets/phone_number_field.dart';
import 'otp_page.dart';

class PhoneEntryPage extends StatefulWidget {
  const PhoneEntryPage({super.key});

  @override
  State<PhoneEntryPage> createState() => _PhoneEntryPageState();
}

class _PhoneEntryPageState extends State<PhoneEntryPage> {
  final _phone = TextEditingController();
  Country _country = Country.parse('SG');

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _pickCountry() => showCountryPicker(
        context: context,
        onSelect: (c) => setState(() => _country = c),
      );

  Future<void> _send() async {
    final provider = context.read<PhoneAuthProvider>();
    final outcome = await provider.sendCode(_country.phoneCode, _phone.text);
    if (!mounted) return;
    await handlePhoneOutcome(context, outcome, provider);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhoneAuthProvider>();
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
                  AppSpacing.xl.h,
                  AppSpacing.xxl.w,
                  AppSpacing.lg.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandMascot(height: AppLayout.mascotHeight),
                    SizedBox(height: AppSpacing.xxl.h),
                    Text(
                      'Enter Phone Number',
                      style:
                          AppTextStyles.screenTitle(context.colors.onSurface),
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    Text(
                      'For Registration and login',
                      style: AppTextStyles.screenSubtitle(
                        context.palette.secondaryText,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxxl.h),
                    PhoneNumberField(
                      controller: _phone,
                      country: _country,
                      onCountryTap: _pickCountry,
                    ),
                  ],
                ),
              ),
            ),
            StickyCtaBar(
              horizontal: AppSpacing.xxl,
              child: PrimaryButton(
                key: const Key('sendCode'),
                label: 'Login',
                loading: provider.busy,
                onPressed: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared by phone entry and OTP pages: route to the next step or show the error.
Future<void> handlePhoneOutcome(
  BuildContext context,
  PhoneOutcome outcome,
  PhoneAuthProvider provider,
) async {
  final navigator = Navigator.of(context);
  switch (outcome) {
    case PhoneOutcome.codeSent:
      await navigator.push(MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const OtpPage(),
        ),
      ));
    case PhoneOutcome.home:
      await navigator.pushNamedAndRemoveUntil(
          AppRoutes.soldierHome, (_) => false);
    case PhoneOutcome.profileCapture:
      await navigator.pushNamed(AppRoutes.profileCapture);
    case PhoneOutcome.failed:
      AppSnackbar.error(context, provider.error ?? 'Verification failed.');
  }
}

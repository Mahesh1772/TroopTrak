import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/dark_section.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/phone_auth_provider.dart';
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

  Future<void> _send() async {
    final provider = context.read<PhoneAuthProvider>();
    final outcome = await provider.sendCode(_country.phoneCode, _phone.text);
    if (!mounted) return;
    await handlePhoneOutcome(context, outcome, provider);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhoneAuthProvider>();
    final text = context.textStyles;
    return DarkSection(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 25.h),
            child: Column(
              children: [
                Image.asset(
                  'lib/assets/phone_auth/troopTrak_logo.png',
                  height: 280.h,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                Text('Enter Phone Number',
                    style: text.displayMedium
                        ?.copyWith(color: AppColors.authLink)),
                SizedBox(height: AppSpacing.sm.h),
                Text('For Registration and login',
                    style:
                        text.titleMedium?.copyWith(color: AppColors.authHint)),
                SizedBox(height: AppSpacing.xxxl.h),
                TextField(
                  key: const Key('phone'),
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Example: 9865 3214',
                    prefixIcon: TextButton(
                      key: const Key('country'),
                      onPressed: () => showCountryPicker(
                        context: context,
                        onSelect: (c) => setState(() => _country = c),
                      ),
                      child: Text(
                        '${_country.flagEmoji}  +${_country.phoneCode}',
                        style: text.titleMedium,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xxl.h),
                PrimaryButton(
                  key: const Key('sendCode'),
                  label: 'Login',
                  loading: provider.busy,
                  onPressed: _send,
                ),
              ],
            ),
          ),
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

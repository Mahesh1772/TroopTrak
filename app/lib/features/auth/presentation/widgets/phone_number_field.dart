import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/field_chrome.dart';
import 'country_chip.dart';

/// The labelled phone field: [CountryChip] inside, a large tabular number,
/// and an example under it.
class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.country,
    required this.onCountryTap,
  });

  final TextEditingController controller;
  final Country country;
  final VoidCallback onCountryTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: 'Phone Number',
          child: TextField(
            key: const Key('phone'),
            controller: controller,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.phoneNumber(palette.onCard),
            decoration: InputDecoration(
              constraints: BoxConstraints.tightFor(
                height: AppLayout.phoneFieldHeight.h,
              ),
              prefixIcon: CountryChip(
                key: const Key('country'),
                country: country,
                onTap: onCountryTap,
              ),
              prefixIconConstraints: fieldPrefixConstraints,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xs.w,
            AppSpacing.sm.h,
            AppSpacing.xs.w,
            0,
          ),
          child: Text(
            'Example: 9865 3214',
            style: AppTextStyles.caption(palette.secondaryText),
          ),
        ),
      ],
    );
  }
}

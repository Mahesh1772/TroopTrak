import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';

const _codeSize = 16.0;
const _dialSize = 18.0;

/// The country and dial code at the start of the phone field, such as
/// "SG +65". It sits on the page colour, 6 px inside the field.
class CountryChip extends StatelessWidget {
  const CountryChip({super.key, required this.country, required this.onTap});

  final Country country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onCard = context.palette.onCard;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.inline.w),
      child: Material(
        color: context.colors.surface,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: SizedBox(
            height: AppLayout.countryChipHeight.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.inline.w,
                children: [
                  Text(
                    country.countryCode,
                    style: AppTextStyles.barlow(
                      _codeSize,
                      FontWeight.w600,
                      onCard,
                    ),
                  ),
                  Text(
                    '+${country.phoneCode}',
                    style: AppTextStyles.figure(
                      _dialSize,
                      FontWeight.w600,
                      onCard,
                    ),
                  ),
                  Icon(
                    Icons.expand_more_rounded,
                    size: AppLayout.countryChipIcon.r,
                    color: context.palette.secondaryText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

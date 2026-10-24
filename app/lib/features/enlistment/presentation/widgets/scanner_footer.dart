import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

const _hintSize = 16.0;
const _orSize = 13.0;
const _orTracking = 0.08;

/// What sits under the reticle: the instruction, an OR divider and the ghost
/// button that reads a code from a picture instead.
class ScannerFooter extends StatelessWidget {
  const ScannerFooter({super.key, required this.onGallery});

  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: Divider(height: 1, thickness: 1, color: AppColors.onCameraLine),
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxxl.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Please scan the QR code on the soldier's profile by placing it "
            'within the frame to add their details.',
            textAlign: TextAlign.center,
            style: AppTextStyles.barlow(
              _hintSize,
              FontWeight.w400,
              AppColors.onCameraText,
            ),
          ),
          SizedBox(height: AppLayout.scanDividerGap.h),
          Row(
            key: const Key('scanOrDivider'),
            spacing: AppSpacing.md.w,
            children: [
              line,
              Text(
                'OR',
                style: AppTextStyles.barlow(
                  _orSize,
                  FontWeight.w600,
                  AppColors.white60,
                ).copyWith(letterSpacing: _orSize.sp * _orTracking),
              ),
              line,
            ],
          ),
          SizedBox(height: AppLayout.scanDividerGap.h),
          PrimaryButton(
            key: const Key('scanGallery'),
            label: 'SELECT FROM GALLERY',
            icon: Icons.photo_library_rounded,
            style: PrimaryButtonStyle.ghost,
            onPressed: onGallery,
          ),
        ],
      ),
    );
  }
}

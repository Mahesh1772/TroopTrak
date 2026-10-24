import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context.dart';
import '../../domain/validators/auth_validators.dart';

/// Six code boxes that share the row evenly. The box taking the next digit has
/// an accent border, and every box turns red when [invalid].
class OtpInput extends StatelessWidget {
  const OtpInput({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.onChanged,
    this.invalid = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool invalid;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final gap = AppSpacing.sm.w;
    const count = AuthValidators.otpLength;
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = _boxTheme(
          palette,
          width: (constraints.maxWidth - gap * (count - 1)) / count,
        );
        return Pinput(
          key: const Key('otp'),
          length: count,
          controller: controller,
          enabled: enabled,
          forceErrorState: invalid,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          defaultPinTheme: box(palette.line, AppLayout.otpBorder),
          focusedPinTheme: box(palette.accent, AppLayout.otpBorderActive),
          errorPinTheme: box(palette.danger, AppLayout.otpBorderActive),
          separatorBuilder: (_) => SizedBox(width: gap),
          cursor: Container(
            width: AppLayout.otpCursor.width.w,
            height: AppLayout.otpCursor.height.h,
            color: palette.accentText,
          ),
          isCursorAnimationEnabled: !MediaQuery.disableAnimationsOf(context),
          onChanged: onChanged,
          onCompleted: onCompleted,
        );
      },
    );
  }

  PinTheme Function(Color, double) _boxTheme(
    AppPalette palette, {
    required double width,
  }) =>
      (border, borderWidth) => PinTheme(
            width: width,
            height: AppLayout.otpBoxHeight.h,
            textStyle: AppTextStyles.otpDigit(palette.onCard),
            decoration: BoxDecoration(
              color: palette.cardElevated,
              borderRadius: BorderRadius.circular(AppRadii.control),
              border: Border.all(color: border, width: borderWidth),
            ),
          );
}

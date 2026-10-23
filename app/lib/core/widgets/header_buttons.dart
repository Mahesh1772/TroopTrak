import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/app_text_styles.dart';

const _labelSize = 13.5;
const _labelTracking = 0.04;
const _iconGap = 6.0;
const _startPadding = 10.0;
const _endPadding = 14.0;

/// A 36 px pill on the gradient header. [solid] is the white main action
/// (SHOW QR CODE); the default is a translucent one (SIGN OUT).
class HeaderPillButton extends StatelessWidget {
  const HeaderPillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.solid = false,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool solid;

  /// Defaults to the label colour.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final content = solid ? AppColors.onGradientSolidText : AppColors.white;
    const shape = StadiumBorder();
    return Semantics(
      button: true,
      child: Material(
        color: solid ? AppColors.white : AppColors.onGradientChip,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onPressed,
          child: SizedBox(
            height: AppLayout.headerPillHeight.h,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: _startPadding.w,
                end: _endPadding.w,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: _iconGap.w,
                children: [
                  Icon(
                    icon,
                    size: AppLayout.headerPillIcon.r,
                    color: iconColor ?? content,
                  ),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.barlow(
                        _labelSize,
                        FontWeight.w600,
                        content,
                      ).copyWith(letterSpacing: _labelSize.sp * _labelTracking),
                    ),
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

/// A round 44 px icon button on the gradient: back or sign out.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.white),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';
import 'state_tone.dart';

const _height = 22.0;
const _iconSize = 18.0;

/// A small pill that names a state, tinted by its [tone].
class StateChip extends StatelessWidget {
  const StateChip(this.label, {super.key, required this.tone, this.icon});

  final String label;
  final StateTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = tone.text(palette);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: tone.tint(palette),
        shape: const StadiumBorder(),
      ),
      child: SizedBox(
        height: _height.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xs.w,
            children: [
              if (icon != null) Icon(icon, size: _iconSize.r, color: color),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.barlow(12.5, FontWeight.w600, color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

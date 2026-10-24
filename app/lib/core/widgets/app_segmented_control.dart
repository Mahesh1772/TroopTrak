import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../theme/app_motion.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_context.dart';

const _fontSize = 14.5;
const _iconSize = 20.0;

class AppSegment<T> {
  const AppSegment({
    required this.value,
    required this.label,
    this.icon,
    this.count,
    this.key,
  });

  final T value;
  final String label;
  final IconData? icon;

  /// Shown after the label in the figure font.
  final int? count;

  /// Defaults to `ValueKey('segment-<value>')`, with an enum's name for value.
  final Key? key;

  Key get effectiveKey => key ?? ValueKey('segment-${_name(value)}');

  static String _name(Object? value) => value is Enum ? value.name : '$value';
}

/// A framed row of equal segments with one selected. [glass] is for use on a
/// gradient: a translucent track with a white selected segment.
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.glass = false,
  });

  final List<AppSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final look = glass
        ? const _Look(
            track: AppColors.onGradientTrack,
            fill: AppColors.white,
            textOn: AppColors.onGradientSolidText,
            textOff: AppColors.onGradientLabel,
          )
        : _Look(
            track: palette.cardElevated,
            fill: palette.card,
            textOn: palette.onCard,
            textOff: palette.secondaryText,
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: look.track,
        borderRadius: BorderRadius.circular(AppRadii.segmented.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppLayout.segmentFrame.r),
        child: Row(
          spacing: AppSpacing.xxs.w,
          children: [
            for (final segment in segments)
              Expanded(
                child: _Segment(
                  key: segment.effectiveKey,
                  segment: segment,
                  selected: segment.value == selected,
                  look: look,
                  onTap: () {
                    if (segment.value != selected) onChanged(segment.value);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Look {
  const _Look({
    required this.track,
    required this.fill,
    required this.textOn,
    required this.textOff,
  });

  final Color track;
  final Color fill;
  final Color textOn;
  final Color textOff;
}

class _Segment extends StatelessWidget {
  const _Segment({
    super.key,
    required this.segment,
    required this.selected,
    required this.look,
    required this.onTap,
  });

  final AppSegment<Object?> segment;
  final bool selected;
  final _Look look;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.quick,
          curve: AppMotion.ease,
          height: AppLayout.segmentHeight.h,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
          decoration: BoxDecoration(
            color: selected ? look.fill : Colors.transparent,
            borderRadius: BorderRadius.circular(
              (AppRadii.segmented - AppLayout.segmentFrame).r,
            ),
            boxShadow: selected ? AppShadows.segment : null,
          ),
          child: Center(
            child: TweenAnimationBuilder<Color?>(
              duration: AppMotion.quick,
              curve: AppMotion.ease,
              tween: ColorTween(end: selected ? look.textOn : look.textOff),
              builder: (context, color, _) => _Content(
                segment: segment,
                color: color!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.segment, required this.color});

  final AppSegment<Object?> segment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = segment.icon;
    final count = segment.count;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.inline.w,
      children: [
        if (icon != null) Icon(icon, size: _iconSize.r, color: color),
        Flexible(
          child: Text(
            segment.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.barlow(_fontSize, FontWeight.w600, color),
          ),
        ),
        if (count != null)
          Text(
            '$count',
            maxLines: 1,
            style: AppTextStyles.figure(_fontSize, FontWeight.w600, color),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/theme_context.dart';

/// A rounded track with an accent fill [fraction] (0 to 1, clamped) of its
/// width. With a [duration] the fill glides to each new fraction. [fillKey]
/// keys the fill.
class FractionBar extends StatelessWidget {
  const FractionBar({
    super.key,
    required this.fraction,
    required this.height,
    this.fillKey,
    this.duration,
  });

  final double fraction;
  final double height;
  final Key? fillKey;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(height.r / 2);
    final fill = DecoratedBox(
      decoration: BoxDecoration(color: palette.accent, borderRadius: radius),
    );
    final factor = fraction.clamp(0.0, 1.0);
    final duration = this.duration;
    return DecoratedBox(
      decoration: BoxDecoration(color: palette.tickOff, borderRadius: radius),
      child: SizedBox(
        height: height.h,
        child: Align(
          alignment: Alignment.centerLeft,
          child: duration == null
              ? FractionallySizedBox(
                  key: fillKey,
                  widthFactor: factor,
                  heightFactor: 1,
                  child: fill,
                )
              : AnimatedFractionallySizedBox(
                  key: fillKey,
                  duration: duration,
                  curve: Curves.linear,
                  widthFactor: factor,
                  heightFactor: 1,
                  child: fill,
                ),
        ),
      ),
    );
  }
}

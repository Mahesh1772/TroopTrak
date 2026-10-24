import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_layout.dart';
import '../theme/app_motion.dart';
import '../theme/app_radii.dart';
import '../theme/theme_context.dart';

/// A thin indeterminate bar: a short accent segment sweeps across a faint
/// track. The segment rests in the middle when the platform asks for reduced
/// motion, so a screen holding it can settle.
class LinearLoader extends StatefulWidget {
  const LinearLoader({super.key});

  @override
  State<LinearLoader> createState() => _LinearLoaderState();
}

class _LinearLoaderState extends State<LinearLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppMotion.loaderSweep);
  late final CurvedAnimation _sweep =
      CurvedAnimation(parent: _controller, curve: AppMotion.ease);

  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const fill = AppLayout.loaderFill;
    const centred = (1 - fill) / 2 / fill;
    return SizedBox(
      width: AppLayout.loaderTrack.width.w,
      height: AppLayout.loaderTrack.height.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: ColoredBox(
          color: palette.tickOff,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: fill,
              child: AnimatedBuilder(
                animation: _sweep,
                builder: (context, child) => FractionalTranslation(
                  translation: Offset(
                    _still
                        ? centred
                        : lerpDouble(
                            AppLayout.loaderStart,
                            AppLayout.loaderEnd,
                            _sweep.value,
                          )!,
                    0,
                  ),
                  child: child,
                ),
                child: DecoratedBox(
                  key: const Key('loaderFill'),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

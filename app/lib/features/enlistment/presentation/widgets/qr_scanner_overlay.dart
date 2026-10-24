import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/theme_context.dart';

/// Dims the camera outside a rounded reticle, with white corner brackets and
/// a scan line that sweeps down and back. The line holds still when the
/// platform asks for reduced motion.
class QrScannerOverlay extends StatefulWidget {
  const QrScannerOverlay({super.key});

  /// Where the reticle sits in an area of [size], in logical pixels.
  static Rect reticleIn(Size size) => Rect.fromCenter(
        center:
            Offset(size.width / 2, size.height * AppLayout.scanReticleCenter),
        width: AppLayout.scanReticle.r,
        height: AppLayout.scanReticle.r,
      );

  @override
  State<QrScannerOverlay> createState() => _QrScannerOverlayState();
}

class _QrScannerOverlayState extends State<QrScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppMotion.scanSweep);
  late final CurvedAnimation _sweep = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.ease,
    reverseCurve: AppMotion.ease.flipped,
  );

  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
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
    final accent = context.palette.accentText;
    final scale = AppLayout.scanReticle.r / AppLayout.scanReticle;
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final reticle = QrScannerOverlay.reticleIn(constraints.biggest);
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _ReticlePainter(
                  reticle: reticle,
                  radius: AppRadii.reticle * scale,
                  bracket: AppLayout.scanBracket * scale,
                  stroke: AppLayout.scanBracketStroke * scale,
                ),
              ),
              Positioned.fromRect(
                key: const Key('scanReticle'),
                rect: reticle,
                child: const SizedBox.expand(),
              ),
              AnimatedBuilder(
                animation: _sweep,
                builder: (context, _) => Positioned(
                  left: reticle.left + AppLayout.scanLineInset * scale,
                  right: constraints.maxWidth -
                      reticle.right +
                      AppLayout.scanLineInset * scale,
                  top: reticle.top +
                      scale *
                          lerpDouble(
                            AppLayout.scanLineStart,
                            AppLayout.scanLineEnd,
                            _still ? 0.5 : _sweep.value,
                          )!,
                  height: AppLayout.scanLineHeight * scale,
                  child: DecoratedBox(
                    key: const Key('scanLine'),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: AppShadows.scanLine(accent),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter({
    required this.reticle,
    required this.radius,
    required this.bracket,
    required this.stroke,
  });

  final Rect reticle;
  final double radius;
  final double bracket;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final dim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(reticle, Radius.circular(radius)));
    canvas.drawPath(dim, Paint()..color = AppColors.scrim);

    final Rect(:left, :top, :right, :bottom) = reticle;
    final corner = Radius.circular(radius);
    final brackets = Path()
      ..moveTo(left, top + bracket)
      ..lineTo(left, top + radius)
      ..arcToPoint(Offset(left + radius, top), radius: corner)
      ..lineTo(left + bracket, top)
      ..moveTo(right - bracket, top)
      ..lineTo(right - radius, top)
      ..arcToPoint(Offset(right, top + radius), radius: corner)
      ..lineTo(right, top + bracket)
      ..moveTo(right, bottom - bracket)
      ..lineTo(right, bottom - radius)
      ..arcToPoint(Offset(right - radius, bottom), radius: corner)
      ..lineTo(right - bracket, bottom)
      ..moveTo(left + bracket, bottom)
      ..lineTo(left + radius, bottom)
      ..arcToPoint(Offset(left, bottom - radius), radius: corner)
      ..lineTo(left, bottom - bracket);
    canvas.drawPath(
      brackets,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_ReticlePainter old) =>
      old.reticle != reticle ||
      old.radius != radius ||
      old.bracket != bracket ||
      old.stroke != stroke;
}

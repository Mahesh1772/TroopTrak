import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Dims everything but a centred square with white corner brackets.
class QrScannerOverlay extends StatelessWidget {
  const QrScannerOverlay({
    super.key,
    required this.overlayColor,
    this.borderRadius = 20,
    this.borderStrokeWidth = 4,
  });

  final Color overlayColor;
  final double borderRadius;
  final double borderStrokeWidth;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final side = (size.width < 400 || size.height < 400) ? 200.0 : 330.0;
    final scanArea = Size.square(side);
    return Stack(
      children: [
        ClipPath(
          clipper: _InvertedClipper(scanArea, borderRadius),
          child: SizedBox.expand(
            child: DecoratedBox(decoration: BoxDecoration(color: overlayColor)),
          ),
        ),
        Align(
          child: CustomPaint(
            foregroundPainter: _CornerPainter(borderRadius, borderStrokeWidth),
            child: SizedBox(width: side + 25, height: side + 25),
          ),
        ),
      ],
    );
  }
}

class _InvertedClipper extends CustomClipper<Path> {
  const _InvertedClipper(this.scanArea, this.borderRadius);

  final Size scanArea;
  final double borderRadius;

  @override
  Path getClip(Size size) => Path()
    ..addRect(Offset.zero & size)
    ..addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: scanArea.width,
        height: scanArea.height,
      ),
      Radius.circular(borderRadius - 4),
    ))
    ..fillType = PathFillType.evenOdd;

  @override
  bool shouldReclip(_InvertedClipper oldClipper) =>
      oldClipper.scanArea != scanArea;
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter(this.borderRadius, this.strokeWidth);

  final double borderRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final corner = 3 * borderRadius;
    final corners = Path()
      ..addRect(Rect.fromLTWH(0, 0, corner, corner))
      ..addRect(Rect.fromLTWH(size.width - corner, 0, corner, corner))
      ..addRect(Rect.fromLTWH(0, size.height - corner, corner, corner))
      ..addRect(Rect.fromLTWH(
          size.width - corner, size.height - corner, corner, corner));
    canvas
      ..clipPath(corners)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(strokeWidth, strokeWidth, size.width - 2 * strokeWidth,
              size.height - 2 * strokeWidth),
          Radius.circular(borderRadius),
        ),
        Paint()
          ..color = AppColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) => false;
}

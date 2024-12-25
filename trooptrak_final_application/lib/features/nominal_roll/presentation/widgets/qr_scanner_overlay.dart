import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QRScannerOverlay extends StatelessWidget {
  final Color overlayColor;

  const QRScannerOverlay({
    super.key,
    required this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double scanArea = 280.w; // Fixed width relative to screen width

    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            overlayColor,
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: scanArea,
                  width: scanArea,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: CustomPaint(
            foregroundPainter: BorderPainter(
              color: theme.colorScheme.tertiary,
              borderRadius: 20.r,
              borderWidth: 3.w,
            ),
            child: SizedBox(
              width: scanArea + 25.w,
              height: scanArea + 25.w,
            ),
          ),
        ),
      ],
    );
  }
}

class BorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double borderWidth;

  BorderPainter({
    required this.color,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final borderLength = size.width / 3; // Shorter corner lines for cleaner look
    final path = Path();

    // Top left corner
    path.moveTo(0, borderLength);
    path.lineTo(0, borderRadius);
    path.arcToPoint(
      Offset(borderRadius, 0),
      radius: Radius.circular(borderRadius),
    );
    path.lineTo(borderLength, 0);

    // Top right corner
    path.moveTo(width - borderLength, 0);
    path.lineTo(width - borderRadius, 0);
    path.arcToPoint(
      Offset(width, borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: false,
    );
    path.lineTo(width, borderLength);

    // Bottom right corner
    path.moveTo(width, height - borderLength);
    path.lineTo(width, height - borderRadius);
    path.arcToPoint(
      Offset(width - borderRadius, height),
      radius: Radius.circular(borderRadius),
      clockwise: false,
    );
    path.lineTo(width - borderLength, height);

    // Bottom left corner
    path.moveTo(borderLength, height);
    path.lineTo(borderRadius, height);
    path.arcToPoint(
      Offset(0, height - borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: false,
    );
    path.lineTo(0, height - borderLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;
}

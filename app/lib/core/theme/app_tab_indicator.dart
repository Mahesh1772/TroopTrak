import 'package:flutter/material.dart';

/// Tab underline inset by a share of the tab width, which UnderlineTabIndicator
/// (pixel insets) cannot do, so two tabs and three keep the same proportions.
class AppTabIndicator extends Decoration {
  const AppTabIndicator({
    required this.color,
    required this.thickness,
    required this.insetFraction,
  });

  final Color color;
  final double thickness;
  final double insetFraction;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _Painter(this);

  @override
  bool operator ==(Object other) =>
      other is AppTabIndicator &&
      other.color == color &&
      other.thickness == thickness &&
      other.insetFraction == insetFraction;

  @override
  int get hashCode => Object.hash(color, thickness, insetFraction);
}

class _Painter extends BoxPainter {
  _Painter(this.indicator);

  final AppTabIndicator indicator;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size!;
    final inset = size.width * indicator.insetFraction;
    final bar = Rect.fromLTWH(
      offset.dx + inset,
      offset.dy + size.height - indicator.thickness,
      size.width - 2 * inset,
      indicator.thickness,
    );
    final corner = Radius.circular(indicator.thickness);
    canvas.drawRRect(
      RRect.fromRectAndCorners(bar, topLeft: corner, topRight: corner),
      Paint()..color = indicator.color,
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pulls [child] up over whatever sits above it: the child paints [overlap]
/// design px higher and the flow gives that much room back.
class OverlapUp extends SingleChildRenderObjectWidget {
  const OverlapUp({super.key, required this.overlap, super.child});

  final double overlap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderOverlapUp(overlap.h);

  @override
  void updateRenderObject(
          BuildContext context, covariant _RenderOverlapUp renderObject) =>
      renderObject.overlap = overlap.h;
}

class _RenderOverlapUp extends RenderShiftedBox {
  _RenderOverlapUp(this._overlap) : super(null);

  double _overlap;

  set overlap(double value) {
    if (_overlap == value) return;
    _overlap = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(
      Size(child.size.width, math.max(0, child.size.height - _overlap)),
    );
    (child.parentData! as BoxParentData).offset =
        Offset(0, size.height - child.size.height);
  }
}

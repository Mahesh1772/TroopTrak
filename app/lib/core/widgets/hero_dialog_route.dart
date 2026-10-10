import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({required WidgetBuilder builder, super.settings})
      : _builder = builder,
        super(fullscreenDialog: false);

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => AppColors.black54;

  @override
  String get barrierLabel => 'Popup dialog open';

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      child;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      _builder(context);
}

/// Ease-out rect tween for [Hero] flights into a [HeroDialogRoute].
class CustomRectTween extends RectTween {
  CustomRectTween({required Rect super.begin, required Rect super.end});

  @override
  Rect lerp(double t) {
    final v = Curves.easeOut.transform(t);
    return Rect.fromLTRB(
      lerpDouble(begin!.left, end!.left, v)!,
      lerpDouble(begin!.top, end!.top, v)!,
      lerpDouble(begin!.right, end!.right, v)!,
      lerpDouble(begin!.bottom, end!.bottom, v)!,
    );
  }
}

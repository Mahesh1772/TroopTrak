import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const quick = Duration(milliseconds: 200);
  static const standard = Duration(milliseconds: 250);
  static const ease = Cubic(0.16, 1, 0.3, 1);
}

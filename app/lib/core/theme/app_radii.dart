import 'package:flutter/painting.dart';

abstract final class AppRadii {
  static const double xs = 5;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double segmented = 13;
  static const double control = 14;
  static const double tile = 16;
  static const double reticle = 18;
  static const double xl = 20;
  static const double sheet = 28;
  static const double pill = 30;
  static const sheetCorners =
      BorderRadius.vertical(top: Radius.circular(sheet));
}

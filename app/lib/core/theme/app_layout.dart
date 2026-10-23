import 'dart:ui';

abstract final class AppLayout {
  static const designSize = Size(390, 844);

  static const navBarHeight = 84.0;
  // The mockup's 84 includes its 22 px home-indicator inset, which SafeArea adds.
  static const shellNavBarHeight = 62.0;
  static const navPill = Size(60, 32);
  static const appBarHeight = 56.0;
  static const segmentHeight = 38.0;
  static const segmentFrame = 3.0;
  static const headerBottom = 22.0;
  static const overlapHeaderBottom = 64.0;
  static const headerOverlap = 48.0;
  static const sectionTop = 28.0;
  static const sectionBottom = 10.0;
  static const listRowMinHeight = 62.0;
  static const reportRowMinHeight = 48.0;
  static const tallyTall = 46.0;
  static const listRowVertical = 10.0;
  static const listDividerInset = 66.0;
  static const dateButtonSize = 48.0;
  static const fabSize = 60.0;
  static const fabIconSize = 28.0;
  static const tabIndicatorHeight = 3.0;
  static const tabIndicatorInsetFraction = 0.14;
  static const sheetHandle = Size(40, 4);
  static const sheetTop = 10.0;
  static const sheetHandleGap = 14.0;
  static const sheetBottom = 34.0;
  static const sheetMaxHeightFraction = 0.9;
  static const buttonHeight = 50.0;
  static const buttonTonalHeight = 40.0;
  static const buttonCompactHeight = 36.0;
  static const buttonIconSize = 20.0;
  static const searchHeight = 46.0;
  static const searchIconSize = 24.0;
  static const fieldLineHeight = 24.0;
  static const fieldIconSize = 20.0;
  static const dateTile = Size(54, 72);
  static const emptyIconSize = 40.0;
  static const emptyVertical = 36.0;
}

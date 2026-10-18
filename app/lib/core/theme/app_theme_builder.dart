import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_layout.dart';
import 'app_palette.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_tab_indicator.dart';
import 'app_text_styles.dart';

const _materialButtonHeight = 40.0;
const _densityStep = 4.0;
const _selectionAlpha = 0.45;

WidgetStateProperty<Color?> _selected(Color on, Color? off) =>
    WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? on : off,
    );

Color _selectedColor(Color on, Color off) => WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected) ? on : off,
    );

ThemeData buildAppTheme({
  required ColorScheme scheme,
  required AppPalette palette,
  required Color appBarColor,
}) {
  final text = AppTextStyles.textTheme(scheme.onSurface);
  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadii.lg),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text,
    primaryTextTheme: text,
    iconTheme: IconThemeData(color: scheme.tertiary),
    extensions: [palette],
    appBarTheme: AppBarTheme(
      backgroundColor: appBarColor,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      titleTextStyle: text.headlineLarge,
    ),
    floatingActionButtonTheme: _floatingActionButtonTheme(palette),
    cardTheme: CardThemeData(
      color: palette.card,
      elevation: 2,
      shadowColor: palette.shadow,
      shape: rounded,
      margin: EdgeInsets.zero,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.card,
      shape: rounded,
      titleTextStyle: text.headlineLarge,
      contentTextStyle: text.bodyMedium,
    ),
    inputDecorationTheme: _inputDecorationTheme(palette),
    // The default cursor and selection use scheme.primary, which vanishes on
    // the card2 fill.
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: palette.accentText,
      selectionHandleColor: palette.accentText,
      selectionColor: palette.accent.withValues(alpha: _selectionAlpha),
    ),
    chipTheme: _chipTheme(scheme, palette),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandIndigo,
        foregroundColor: AppColors.white,
        textStyle: text.labelLarge,
        shape: rounded,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: text.labelLarge,
      ),
    ),
    tabBarTheme: _tabBarTheme(scheme, palette),
    navigationBarTheme: _navigationBarTheme(scheme, palette),
    switchTheme: _switchTheme(palette),
    segmentedButtonTheme: _segmentedButtonTheme(scheme, palette),
    bottomSheetTheme: _bottomSheetTheme(palette),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.cardElevated,
      contentTextStyle: text.bodySmall?.copyWith(color: palette.onCard),
      shape: rounded,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: palette.card,
      headerBackgroundColor: AppColors.accent,
      headerForegroundColor: AppColors.white,
      dayForegroundColor: _selected(AppColors.white, scheme.onSurface),
      dayBackgroundColor: _selected(AppColors.accent, null),
      yearForegroundColor: _selected(AppColors.white, scheme.onSurface),
      yearBackgroundColor: _selected(AppColors.accent, null),
      todayForegroundColor: _selected(AppColors.white, AppColors.accent),
      todayBackgroundColor: _selected(AppColors.accent, null),
      todayBorder: const BorderSide(color: AppColors.accent),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
      ),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: palette.card,
      dialHandColor: AppColors.accent,
      dialBackgroundColor: palette.cardElevated,
      hourMinuteColor: _selectedColor(AppColors.accent, palette.cardElevated),
      hourMinuteTextColor: _selectedColor(AppColors.white, scheme.onSurface),
      dayPeriodColor: _selectedColor(AppColors.accent, palette.cardElevated),
      dayPeriodTextColor: _selectedColor(AppColors.white, scheme.onSurface),
      entryModeIconColor: AppColors.accent,
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
      ),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
      ),
    ),
  );
}

// The shell paints the gradient pill, so the indicator is transparent and only
// shapes the ripple (Material fixes it at 64x32); the selected icon is white
// because that pill sits behind it.
NavigationBarThemeData _navigationBarTheme(
  ColorScheme scheme,
  AppPalette palette,
) {
  final active = AppTextStyles.barlow(12.5, FontWeight.w600, scheme.onSurface);
  final idle =
      AppTextStyles.barlow(12.5, FontWeight.w500, palette.secondaryText);
  return NavigationBarThemeData(
    height: AppLayout.navBarHeight,
    backgroundColor: palette.navBar,
    indicatorColor: Colors.transparent,
    indicatorShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.tile),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? active : idle,
    ),
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? AppColors.white
            : palette.secondaryText,
      ),
    ),
  );
}

// A blank thumb icon makes Material draw the same 24 px thumb on and off; the
// 52x32 track cannot be themed.
SwitchThemeData _switchTheme(AppPalette palette) => SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(AppColors.white),
      trackColor: _selected(palette.success, palette.tickOff),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbIcon: const WidgetStatePropertyAll(Icon(null)),
    );

// Material has no padded track, so a frame in the unselected colour stands in
// for it and the density makes the segment 38 px inside the frame. Callers pass
// showSelectedIcon: false, as the mockup has no check mark.
SegmentedButtonThemeData _segmentedButtonTheme(
  ColorScheme scheme,
  AppPalette palette,
) =>
    SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          AppTextStyles.barlow(14.5, FontWeight.w600, scheme.onSurface),
        ),
        backgroundColor: _selected(palette.card, palette.cardElevated),
        foregroundColor: _selected(scheme.onSurface, palette.secondaryText),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: palette.cardElevated,
            width: AppLayout.segmentFrame,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.segmented),
          ),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(
          vertical: (AppLayout.segmentHeight +
                  2 * AppLayout.segmentFrame -
                  _materialButtonHeight) /
              _densityStep,
        ),
      ),
    );

BottomSheetThemeData _bottomSheetTheme(AppPalette palette) =>
    BottomSheetThemeData(
      backgroundColor: palette.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: palette.tickOff,
      dragHandleSize: AppLayout.sheetHandle,
    );

// A text tab is 46 high plus a 2 px indicator gap, so 1 px of label padding top
// and bottom makes the mockup's 50. The 4 px side padding lets a 19 px icon,
// a 6 px gap and 'ATTENDANCE' fit one line in a third of the screen.
TabBarThemeData _tabBarTheme(ColorScheme scheme, AppPalette palette) {
  final label = AppTextStyles.barlow(13, FontWeight.w600, scheme.onSurface);
  final tracked = label.copyWith(letterSpacing: label.fontSize! * 0.06);
  return TabBarThemeData(
    labelColor: scheme.onSurface,
    unselectedLabelColor: palette.secondaryText,
    labelStyle: tracked,
    unselectedLabelStyle: tracked,
    labelPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xs,
      vertical: 1,
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    indicator: AppTabIndicator(
      color: palette.accent,
      thickness: AppLayout.tabIndicatorHeight,
      insetFraction: AppLayout.tabIndicatorInsetFraction,
    ),
    dividerColor: palette.line,
    dividerHeight: 1,
  );
}

// Borders are drawn inside the box, so the 2 px rings never resize the field:
// 14 + 24 (16 px text at 1.5) + 14 = 52.
InputDecorationThemeData _inputDecorationTheme(AppPalette palette) {
  OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(color: color, width: width),
      );
  final rest = outline(palette.line, 1);
  final error = outline(palette.danger, 2);
  final muted = TextStyle(color: palette.mutedText);
  return InputDecorationThemeData(
    filled: true,
    fillColor: palette.cardElevated,
    contentPadding: const EdgeInsets.all(AppSpacing.control),
    hintStyle: muted,
    labelStyle: muted,
    errorStyle: AppTextStyles.barlow(13.5, FontWeight.w400, palette.leaveText),
    prefixIconColor: palette.secondaryText,
    suffixIconColor: palette.secondaryText,
    border: rest,
    enabledBorder: rest,
    disabledBorder: rest,
    focusedBorder: outline(palette.accent, 2),
    errorBorder: error,
    focusedErrorBorder: error,
  );
}

// The 1 px border wraps Material's 32 px body, so the chip is 34; the selected
// border is transparent, not none, to keep that size. ChoiceChip reads
// secondaryLabelStyle when selected, the state colour covers other chips.
ChipThemeData _chipTheme(ColorScheme scheme, AppPalette palette) {
  final label = AppTextStyles.barlow(14.5, FontWeight.w500, scheme.onSurface);
  return ChipThemeData(
    backgroundColor: palette.cardElevated,
    selectedColor: palette.accent,
    showCheckmark: false,
    shape: const StadiumBorder(),
    side: WidgetStateBorderSide.resolveWith(
      (states) => BorderSide(
        color: states.contains(WidgetState.selected)
            ? Colors.transparent
            : palette.line,
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.control - 1),
    labelPadding: EdgeInsets.zero,
    labelStyle: label.copyWith(
      color: _selectedColor(AppColors.white, scheme.onSurface),
    ),
    secondaryLabelStyle: label.copyWith(color: AppColors.white),
  );
}

// A theme cannot hold the button gradient: the flat colour is its end and the
// widget paints the gradient.
FloatingActionButtonThemeData _floatingActionButtonTheme(AppPalette palette) =>
    FloatingActionButtonThemeData(
      backgroundColor: palette.buttonGradient.last,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      sizeConstraints: const BoxConstraints.tightFor(
        width: AppLayout.fabSize,
        height: AppLayout.fabSize,
      ),
      iconSize: AppLayout.fabIconSize,
    );

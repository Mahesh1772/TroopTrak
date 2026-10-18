import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.card,
    required this.cardElevated,
    required this.onCard,
    required this.muted,
    required this.shadow,
    required this.success,
    required this.danger,
    required this.warning,
    required this.accent,
    required this.headerGradient,
    required this.buttonGradient,
    required this.conductTile,
    required this.personTile,
    required this.onTile,
    required this.statusExcuse,
    required this.statusLeave,
    required this.statusMedical,
    required this.pastTile,
    required this.page,
    required this.pageLine,
    required this.navBar,
    required this.sheet,
    required this.secondaryText,
    required this.mutedText,
    required this.line,
    required this.hover,
    required this.tickOff,
    required this.tickFuture,
    required this.accentText,
    required this.successText,
    required this.excuseText,
    required this.leaveText,
    required this.medicalText,
    required this.rankPlate,
    required this.rankPlateDark,
    required this.duty,
  });

  final Color card;
  final Color cardElevated;
  final Color onCard;
  final Color muted;
  final Color shadow;
  final Color success;
  final Color danger;
  final Color warning;
  final Color accent;
  final List<Color> headerGradient;
  final List<Color> buttonGradient;
  final Color conductTile;
  final Color personTile;
  final Color onTile;
  final Color statusExcuse;
  final Color statusLeave;
  final Color statusMedical;
  final Color pastTile;
  final Color page;
  final Color pageLine;
  final Color navBar;
  final Color sheet;
  final Color secondaryText;
  final Color mutedText;
  final Color line;
  final Color hover;
  final Color tickOff;
  final Color tickFuture;
  final Color accentText;
  final Color successText;
  final Color excuseText;
  final Color leaveText;
  final Color medicalText;
  final Color rankPlate;
  final Color rankPlateDark;
  final Color duty;

  static const dark = AppPalette(
    card: AppColors.darkCard,
    cardElevated: AppColors.darkCardElevated,
    onCard: AppColors.white,
    muted: AppColors.grey,
    shadow: AppColors.black54,
    success: AppColors.success,
    danger: AppColors.danger,
    warning: AppColors.warning,
    accent: AppColors.accent,
    headerGradient: [AppColors.brandIndigo, AppColors.brandViolet],
    buttonGradient: [
      AppColors.buttonGradientStart,
      AppColors.buttonGradientEnd
    ],
    conductTile: AppColors.conductTile,
    personTile: AppColors.personTile,
    onTile: AppColors.white,
    statusExcuse: AppColors.statusExcuse,
    statusLeave: AppColors.statusLeave,
    statusMedical: AppColors.statusMedical,
    pastTile: AppColors.pastTileDark,
    page: AppColors.darkPage,
    pageLine: AppColors.darkPageLine,
    navBar: AppColors.darkPrimary,
    sheet: AppColors.darkCardElevated,
    secondaryText: AppColors.darkSecondaryText,
    mutedText: AppColors.darkMutedText,
    line: AppColors.darkLine,
    hover: AppColors.darkHover,
    tickOff: AppColors.darkTickOff,
    tickFuture: AppColors.darkTickFuture,
    accentText: AppColors.darkAccentText,
    successText: AppColors.darkSuccessText,
    excuseText: AppColors.darkExcuseText,
    leaveText: AppColors.darkLeaveText,
    medicalText: AppColors.darkMedicalText,
    rankPlate: AppColors.darkRankPlate,
    rankPlateDark: AppColors.darkCard,
    duty: AppColors.calendarDuty,
  );

  static const light = AppPalette(
    card: AppColors.lightCard,
    cardElevated: AppColors.lightCardElevated,
    onCard: AppColors.black,
    muted: AppColors.grey,
    shadow: AppColors.black54,
    success: AppColors.success,
    danger: AppColors.danger,
    warning: AppColors.warning,
    accent: AppColors.accent,
    headerGradient: [AppColors.brandIndigo, AppColors.brandViolet],
    buttonGradient: [
      AppColors.buttonGradientStart,
      AppColors.buttonGradientEnd
    ],
    conductTile: AppColors.conductTile,
    personTile: AppColors.personTile,
    onTile: AppColors.white,
    statusExcuse: AppColors.statusExcuse,
    statusLeave: AppColors.statusLeave,
    statusMedical: AppColors.statusMedical,
    pastTile: AppColors.darkPrimary,
    page: AppColors.lightPage,
    pageLine: AppColors.lightPageLine,
    navBar: AppColors.white,
    sheet: AppColors.lightCard,
    secondaryText: AppColors.lightSecondaryText,
    mutedText: AppColors.lightMutedText,
    line: AppColors.lightLine,
    hover: AppColors.lightHover,
    tickOff: AppColors.lightTickOff,
    tickFuture: AppColors.lightTickFuture,
    accentText: AppColors.lightAccentText,
    successText: AppColors.lightSuccessText,
    excuseText: AppColors.lightExcuseText,
    leaveText: AppColors.lightLeaveText,
    medicalText: AppColors.lightMedicalText,
    rankPlate: AppColors.lightCardElevated,
    rankPlateDark: AppColors.darkCard,
    duty: AppColors.calendarDuty,
  );

  @override
  AppPalette copyWith({Color? card, Color? onCard}) => AppPalette(
        card: card ?? this.card,
        cardElevated: cardElevated,
        onCard: onCard ?? this.onCard,
        muted: muted,
        shadow: shadow,
        success: success,
        danger: danger,
        warning: warning,
        accent: accent,
        headerGradient: headerGradient,
        buttonGradient: buttonGradient,
        conductTile: conductTile,
        personTile: personTile,
        onTile: onTile,
        statusExcuse: statusExcuse,
        statusLeave: statusLeave,
        statusMedical: statusMedical,
        pastTile: pastTile,
        page: page,
        pageLine: pageLine,
        navBar: navBar,
        sheet: sheet,
        secondaryText: secondaryText,
        mutedText: mutedText,
        line: line,
        hover: hover,
        tickOff: tickOff,
        tickFuture: tickFuture,
        accentText: accentText,
        successText: successText,
        excuseText: excuseText,
        leaveText: leaveText,
        medicalText: medicalText,
        rankPlate: rankPlate,
        rankPlateDark: rankPlateDark,
        duty: duty,
      );

  @override
  AppPalette lerp(AppPalette? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

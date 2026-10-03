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
      );

  @override
  AppPalette lerp(AppPalette? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

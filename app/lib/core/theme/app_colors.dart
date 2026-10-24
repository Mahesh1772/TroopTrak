import 'package:flutter/material.dart';

import '../constants/ranks.dart';

abstract final class AppColors {
  static const brandIndigo = Color(0xFF481EE5);
  static const brandViolet = Color(0xFF823CE5);
  static const accent = Color(0xFF8147E6);

  static const darkPrimary = Color(0xFF202433);
  static const darkSurface = Color(0xFF151922);
  static const darkCard = Color(0xFF2D3241);
  static const darkCardElevated = Color(0xFF232837);
  static const darkPage = Color(0xFF0D1016);
  static const darkPageLine = Color(0xFF1C2130);
  static const darkSecondaryText = Color(0xFFB3B8C8);
  static const darkMutedText = Color(0xFF8C92A5);
  static const darkLine = Color(0x14FFFFFF);
  static const darkHover = Color(0x0FFFFFFF);
  static const darkTickOff = Color(0x21FFFFFF);
  static const darkTickFuture = Color(0x0DFFFFFF);
  static const darkAccentText = Color(0xFFB196F5);
  static const darkSuccessText = Color(0xFF6CCB70);
  static const darkExcuseText = Color(0xFFFF9840);
  static const darkLeaveText = Color(0xFFFF7A70);
  static const darkMedicalText = Color(0xFF5AA9F0);
  static const darkRankPlate = Color(0xFFE9EBF4);

  static const lightPrimary = Color(0xFFDBDBDB);
  static const lightSurface = Color(0xFFF3F6FE);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardElevated = Color(0xFFEDEFF7);
  static const lightPage = Color(0xFFE4E8F2);
  static const lightPageLine = Color(0xFFD2D8E6);
  static const lightSecondaryText = Color(0xFF4B5168);
  static const lightMutedText = Color(0xFF6E7489);
  static const lightLine = Color(0x1412151D);
  static const lightHover = Color(0x0D12151D);
  static const lightTickOff = Color(0xFFDADEEA);
  static const lightTickFuture = Color(0xFFEBEEF6);
  static const lightAccentText = Color(0xFF5B2BD0);
  static const lightSuccessText = Color(0xFF2E7D32);
  static const lightExcuseText = Color(0xFFC25400);
  static const lightLeaveText = Color(0xFFC62828);
  static const lightMedicalText = Color(0xFF1565C0);

  static const tooltipBackground = Color(0xFF07080C);
  static const tooltipDetail = darkSecondaryText;

  static const onGradientLabel = Color(0xCCFFFFFF);
  static const onGradientGreeting = Color(0xDBFFFFFF);
  // One 20% white for the mockup's 18% (profile card) and 22% (headers).
  static const onGradientTickOff = Color(0x33FFFFFF);
  static const onGradientTickFuture = Color(0x12FFFFFF);
  static const onGradientInCamp = Color(0xFF7EE07F);
  static const onGradientExcuse = Color(0xFFFFA84D);
  static const onGradientLeave = Color(0xFFFF8A80);
  static const onGradientMedical = Color(0xFF82C4FF);
  static const onGradientTrack = Color(0x24FFFFFF);
  static const onGradientSubtitle = Color(0xD1FFFFFF);
  static const onGradientSolidText = Color(0xFF2B1580);
  // One 16% white for the mockup's 15% unit pills and 16% header pills.
  static const onGradientChip = Color(0x29FFFFFF);
  static const onGradientPanel = Color(0x470A0628);
  static const onGradientBadge = Color(0x2E000000);
  static const segmentShadow = Color(0x59000000);
  static const scrim = Color(0x9E05060C);
  static const onCameraText = Color(0xE0FFFFFF);
  static const onCameraLine = Color(0x33FFFFFF);
  static const qrInk = darkSurface;
  static const raisedShadowDark = Color(0x99000000);
  static const raisedShadowLight = Color(0x59202433);

  static const white = Color(0xFFFFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const black = Color(0xFF000000);
  static const black54 = Color(0x8A000000);
  static const grey = Color(0xFF9E9E9E);

  static const success = Color(0xFF4CAF50);
  static const danger = Color(0xFFF44336);
  static const warning = Color(0xFFFFC107);

  static const buttonGradientStart = Color(0xFF7E57C2);
  static const buttonGradientEnd = Color(0xFF512DA8);

  static const conductTile = Color(0xFF350E91);
  static const personTile = Color(0xFF353B4F);
  static const personTileMuted = Color(0xFF1D202B);
  static const tileBorder = Color(0x402196F3);
  static const authField = Color(0xFF2D3C44);
  static const roleCard = Color(0xFF212836);
  static const roleShadowLight = Color(0xFF474B50);
  static const roleShadowDark = Color(0xFF0B0F14);
  static const white60 = Color(0x99FFFFFF);
  static const deepPurple = Color(0xFF673AB7);
  static const authAccent = Color(0xFF64FFDA);
  static const authLink = Color(0xFFBA68C8);
  static const authSubtitle = Color(0xFFAB47BC);
  static const authHint = Color(0xFFE1BEE7);
  static const authIcon = Color(0xFF7C4DFF);
  static const navActiveEnd = Color(0xFF5E35B1);
  static const navPillGradient = [brandIndigo, navActiveEnd];

  static const statusExcuse = Color(0xFFFF6F00);
  static const statusLeave = Color(0xFFF44336);
  static const statusMedical = Color(0xFF1E88E5);
  static const statusExcuseEnd = Color(0xFFE65100);
  static const statusLeaveEnd = Color(0xFFC62828);
  static const statusMedicalEnd = Color(0xFF1565C0);
  static const info = Color(0xFF2196F3);
  static const calendarDuty = Color(0xFFE91E63);

  static const chartWoses = Color(0xFF2196F3);

  static const rankEnlisted = Color(0xFF4E342E);
  static const rankSpecialistCadet = Color(0xFF8D6E63);
  static const rankSpecialist = Color(0xFF303F9F);
  static const rankWarrantOfficer = Color(0xFF5C6BC0);
  static const rankOfficerCadet = Color(0xFF004D40);
  static const rankJuniorOfficer = Color(0xFF00695C);
  static const rankSeniorOfficer = Color(0xFF26A69A);

  static Color rankTile(RankGroup group) => switch (group) {
        RankGroup.enlisted => rankEnlisted,
        RankGroup.specialistCadet => rankSpecialistCadet,
        RankGroup.specialist => rankSpecialist,
        RankGroup.warrantOfficer => rankWarrantOfficer,
        RankGroup.officerCadet => rankOfficerCadet,
        RankGroup.juniorOfficer => rankJuniorOfficer,
        RankGroup.seniorOfficer || RankGroup.unknown => rankSeniorOfficer,
      };
}

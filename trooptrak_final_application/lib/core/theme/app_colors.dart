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

  static const lightPrimary = Color(0xFFDBDBDB);
  static const lightSurface = Color(0xFFF3F6FE);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardElevated = Color(0xFFEDEFF7);

  static const white = Color(0xFFFFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const black = Color(0xFF000000);
  static const black54 = Color(0x8A000000);
  static const grey = Color(0xFF9E9E9E);

  static const success = Color(0xFF4CAF50);
  static const danger = Color(0xFFF44336);
  static const dangerGradientEnd = Color(0xFFED837C);
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
  static const navInactive = Color(0xFF9575CD);
  static const navActiveEnd = Color(0xFF5E35B1);

  static const statusExcuse = Color(0xFFFF6F00);
  static const statusLeave = Color(0xFFF44336);
  static const statusMedical = Color(0xFF1E88E5);
  static const pastTileDark = Color(0xFF908F8F);
  static const info = Color(0xFF2196F3);
  static const bookIn = Color(0xFF43A047);

  static const chartOfficers = Color(0xFFF44336);
  static const chartWoses = Color(0xFF2196F3);
  static const chartStatus = Color(0xFFFFEB3B);
  static const chartMedical = Color(0xFF40C4FF);
  static const chartRemainder = Color(0x1A2196F3);

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

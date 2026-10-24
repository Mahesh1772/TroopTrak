import 'ranks.dart';

abstract final class RankAssets {
  static const directory = 'lib/assets/army-ranks';
  static const menIcon = '$directory/men.png';
  static const soldierIcon = '$directory/soldier.png';

  static String insignia(String rank) =>
      '$directory/${rank.trim().toLowerCase()}.png';

  static String personIcon(String rank) =>
      Ranks.groupOf(rank) == RankGroup.enlisted ? menIcon : soldierIcon;

  /// Warrant officer insignia are pale line art, so they sit on a dark plate.
  static bool paleInsignia(String rank) =>
      Ranks.groupOf(rank) == RankGroup.warrantOfficer;
}

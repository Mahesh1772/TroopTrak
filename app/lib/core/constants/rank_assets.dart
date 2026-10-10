import 'ranks.dart';

abstract final class RankAssets {
  static const directory = 'lib/assets/army-ranks';
  static const menIcon = '$directory/men.png';
  static const soldierIcon = '$directory/soldier.png';

  static String insignia(String rank) =>
      '$directory/${rank.trim().toLowerCase()}.png';

  static String personIcon(String rank) =>
      Ranks.groupOf(rank) == RankGroup.enlisted ? menIcon : soldierIcon;

  /// Dark insignia images that the source tints white on coloured tiles.
  static bool tintInsignia(String rank) => switch (Ranks.groupOf(rank)) {
        RankGroup.enlisted ||
        RankGroup.specialist ||
        RankGroup.warrantOfficer =>
          true,
        _ => false,
      };
}

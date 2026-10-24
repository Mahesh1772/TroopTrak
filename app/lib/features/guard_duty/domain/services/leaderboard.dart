import '../../../soldiers/domain/entities/soldier.dart';
import 'self_name.dart';

abstract final class Leaderboard {
  static double topPoints(Iterable<Soldier> soldiers) => soldiers.fold(
        0.0,
        (top, soldier) => soldier.points > top ? soldier.points : top,
      );

  /// Share of the top score, 0 when nobody has scored.
  static double barFraction(double points, double top) =>
      top <= 0 ? 0 : (points / top).clamp(0.0, 1.0);

  static bool isSelf(Soldier soldier, String? selfName) =>
      SelfName.matches(soldier.name, selfName);
}

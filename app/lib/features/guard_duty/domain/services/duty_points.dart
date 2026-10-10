import 'package:equatable/equatable.dart';

import '../../../soldiers/domain/entities/soldier.dart';

typedef DayPoints = ({double points, String dayType});

/// R7 points and day label by weekday. K4 fix: Sunday reads "Weekend".
abstract final class DutyPoints {
  static const noDate = (points: 0.0, dayType: 'Select a duty date! 😄');

  static DayPoints forDate(DateTime? date) => switch (date?.weekday) {
        null => noDate,
        DateTime.friday => (points: 1.5, dayType: 'Weekday (Friday) Duty 😖'),
        DateTime.saturday => (
            points: 2.5,
            dayType: 'Weekend (Saturday) Duty 😵‍💫'
          ),
        DateTime.sunday => (points: 2.0, dayType: 'Weekend (Sunday) Duty 🤧'),
        _ => (points: 1.0, dayType: 'Weekday Duty 🫣'),
      };
}

/// How one soldier's points move: `max(0, current - subtract) + add` (R8, R9).
class PointsChange extends Equatable {
  const PointsChange({this.subtract = 0, this.add = 0});

  final double subtract;
  final double add;

  double applyTo(double current) =>
      Soldier.pointsAfter(current, -subtract) + add;

  @override
  List<Object?> get props => [subtract, add];
}

/// Point changes per soldier name for each duty write.
abstract final class DutyLedger {
  /// R8: every participant gains the duty's points.
  static Map<String, PointsChange> add(
          Map<String, String> participants, double points) =>
      {for (final name in participants.keys) name: PointsChange(add: points)};

  /// R9: every participant loses the duty's points, never below zero.
  static Map<String, PointsChange> delete(
          Map<String, String> participants, double points) =>
      {
        for (final name in participants.keys)
          name: PointsChange(subtract: points)
      };

  /// K6 fix: old participants lose the old points (clamped), then new
  /// participants gain the new points.
  static Map<String, PointsChange> update({
    required Map<String, String> before,
    required double beforePoints,
    required Map<String, String> after,
    required double afterPoints,
  }) =>
      {
        for (final name in {...before.keys, ...after.keys})
          name: PointsChange(
            subtract: before.containsKey(name) ? beforePoints : 0,
            add: after.containsKey(name) ? afterPoints : 0,
          ),
      };
}

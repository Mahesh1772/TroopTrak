import 'package:equatable/equatable.dart';

class Duty extends Equatable {
  const Duty({
    required this.id,
    required this.start,
    required this.end,
    required this.dayType,
    required this.points,
    this.participants = const {},
  });

  /// R10a: a duty has at most ten participant slots.
  static const maxSlots = 10;

  final String id;

  /// Duty day and start time (`dutyDate` + `startTime`).
  final DateTime start;

  /// End time; on the duty day as stored (guard duties may run overnight).
  final DateTime end;
  final String dayType;
  final double points;

  /// Soldier name → rank, in slot order (R10a).
  final Map<String, String> participants;

  DateTime get day => DateTime(start.year, start.month, start.day);

  bool includes(String soldierName) => participants.containsKey(soldierName);

  Duty copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    String? dayType,
    double? points,
    Map<String, String>? participants,
  }) =>
      Duty(
        id: id ?? this.id,
        start: start ?? this.start,
        end: end ?? this.end,
        dayType: dayType ?? this.dayType,
        points: points ?? this.points,
        participants: participants ?? this.participants,
      );

  @override
  List<Object?> get props => [id, start, end, dayType, points, participants];
}

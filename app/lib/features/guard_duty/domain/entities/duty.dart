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

  static final _pictographs =
      RegExp(r'[\u{1F000}-\u{1FAFF}\u2600-\u27BF\u200D\uFE0F]', unicode: true);

  /// D11: a day type without the emoji the source stored after it.
  static String plainLabel(String dayType) =>
      dayType.replaceAll(_pictographs, '').trim();

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

  /// D10: an end not after the start runs into the next day.
  bool get endsNextDay => !end.isAfter(start);

  int get filledSlots => participants.length.clamp(0, maxSlots);

  /// One flag per slot, in slot order; true where a participant fills it.
  List<bool> get slots => [for (var i = 0; i < maxSlots; i++) i < filledSlots];

  String get dayLabel => plainLabel(dayType);

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

import 'package:equatable/equatable.dart';

class Conduct extends Equatable {
  const Conduct({
    required this.id,
    required this.name,
    required this.type,
    required this.start,
    required this.end,
    this.participants = const [],
    this.soldierReason = const {},
  });

  final String id;
  final String name;
  final String type;

  /// Day and start time; `startDate` + `startTime` in Firestore.
  final DateTime start;

  /// End time on the same day as [start].
  final DateTime end;

  /// Soldier names taking part (R13 links soldiers by name).
  final List<String> participants;

  /// Auto-exclusion reasons (R5), soldier name → status name.
  final Map<String, String> soldierReason;

  DateTime get day => DateTime(start.year, start.month, start.day);

  bool includes(String soldierName) => participants.contains(soldierName);

  /// Reason shown for a soldier who is not taking part.
  static const removedReason = 'Removed from conduct';

  String reasonFor(String soldierName) =>
      soldierReason[soldierName] ?? removedReason;

  Conduct copyWith({
    String? id,
    String? name,
    String? type,
    DateTime? start,
    DateTime? end,
    List<String>? participants,
    Map<String, String>? soldierReason,
  }) =>
      Conduct(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        start: start ?? this.start,
        end: end ?? this.end,
        participants: participants ?? this.participants,
        soldierReason: soldierReason ?? this.soldierReason,
      );

  @override
  List<Object?> get props =>
      [id, name, type, start, end, participants, soldierReason];
}

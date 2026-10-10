import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/data/firestore_helpers.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/conduct.dart';

abstract final class ConductModel {
  static final _unparseable = DateTime(1970);

  static Conduct fromMap(String id, Map<String, dynamic> map) {
    final day =
        parseDay(map[ConductFields.startDate]?.toString()) ?? _unparseable;
    DateTime at(String field) {
      final time = parseTime(map[field]?.toString());
      return time == null ? day : combineDayAndTime(day, time);
    }

    final participants = map[ConductFields.participants];
    final reasons = map[ConductFields.soldierReason];
    return Conduct(
      id: id,
      name: readString(map[ConductFields.conductName]),
      type: readString(map[ConductFields.conductType]),
      start: at(ConductFields.startTime),
      end: at(ConductFields.endTime),
      participants: participants is List
          ? [for (final p in participants) p.toString()]
          : const [],
      soldierReason: reasons is Map
          ? {
              for (final e in reasons.entries)
                e.key.toString(): e.value.toString(),
            }
          : const {},
    );
  }

  static Map<String, dynamic> toMap(Conduct conduct) => {
        ConductFields.conductName: conduct.name,
        ConductFields.conductType: conduct.type,
        ConductFields.startDate: formatDay(conduct.start),
        ConductFields.startTime: formatTime(conduct.start),
        ConductFields.endTime: formatTime(conduct.end),
        ConductFields.participants: conduct.participants,
        ConductFields.soldierReason: conduct.soldierReason,
      };
}

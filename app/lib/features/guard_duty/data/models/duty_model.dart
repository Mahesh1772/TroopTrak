import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/data/firestore_helpers.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/duty.dart';

abstract final class DutyModel {
  static final _unparseable = DateTime(1970);

  /// Empty-slot keys (`NA0`..`NA9`) the source used inside its form state.
  static final _placeholder = RegExp(r'^NA\d+$');

  static Duty fromMap(String id, Map<String, dynamic> map) {
    final day = parseDay(map[DutyFields.dutyDate]?.toString()) ?? _unparseable;
    DateTime at(String field) {
      final time = parseTime(map[field]?.toString());
      return time == null ? day : combineDayAndTime(day, time);
    }

    final participants = map[DutyFields.participants];
    return Duty(
      id: id,
      start: at(DutyFields.startTime),
      end: at(DutyFields.endTime),
      dayType: readString(map[DutyFields.dayType]),
      points: readDouble(map[DutyFields.points]),
      participants: participants is Map
          ? {
              for (final e in participants.entries)
                if (!_placeholder.hasMatch(e.key.toString()))
                  e.key.toString(): e.value.toString(),
            }
          : const {},
    );
  }

  static Map<String, dynamic> toMap(Duty duty) => {
        DutyFields.points: duty.points,
        DutyFields.dayType: duty.dayType,
        DutyFields.dutyDate: formatDay(duty.start),
        DutyFields.startTime: formatTime(duty.start),
        DutyFields.endTime: formatTime(duty.end),
        DutyFields.participants: duty.participants,
      };
}

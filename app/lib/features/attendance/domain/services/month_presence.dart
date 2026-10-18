import 'package:equatable/equatable.dart';

import '../../../../core/utils/date_formats.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../statuses/domain/entities/status.dart';
import '../../../statuses/domain/services/parade_roster.dart';
import '../../../statuses/domain/services/parade_state.dart';
import '../entities/attendance_record.dart';

/// Past days are read at noon, so a 07:00-in, 18:00-out commuter shows in.
const _pastDayReadHour = 12;

class MonthPresence extends Equatable {
  const MonthPresence(this.days);

  /// Index 0 is day 1; null is a day not yet reached.
  final List<ParadeState?> days;

  int get elapsed => days.nonNulls.length;

  /// D9: an excuse counts as in camp; leave, medical and out do not.
  int get inCampDays => days.nonNulls.where((state) => state.isInCamp).length;

  @override
  List<Object?> get props => [days];
}

/// The parade state of [soldier] on each day of [month]'s month; a day after
/// [now] is null.
///
/// Presence is R21 over [records], the soldier's own: read at noon on a past
/// day and at [now] today, so today matches the live state. A day before the
/// first record uses the soldier's stored `isInCamp`, with no inference. The
/// state then comes from [paradeRoster] for that day (R3, D9), which ignores
/// other soldiers' [statuses].
MonthPresence monthPresence({
  required Soldier soldier,
  required Iterable<AttendanceRecord> records,
  required Iterable<Status> statuses,
  required DateTime month,
  required DateTime now,
}) {
  ParadeState? stateOn(DateTime day) {
    final daysAhead = dayDifference(day, now);
    if (daysAhead > 0) return null;
    final readAt = daysAhead == 0
        ? now
        : DateTime(day.year, day.month, day.day, _pastDayReadHour);
    final inCamp = effectiveInCamp(records, readAt, fallback: soldier.isInCamp);
    return paradeRoster([soldier.copyWith(isInCamp: inCamp)], statuses, day)
        .single
        .state;
  }

  final length = DateTime(month.year, month.month + 1, 0).day;
  return MonthPresence([
    for (var day = 1; day <= length; day++)
      stateOn(DateTime(month.year, month.month, day)),
  ]);
}

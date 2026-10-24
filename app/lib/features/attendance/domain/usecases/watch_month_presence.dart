import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../statuses/domain/entities/status.dart';
import '../../../statuses/domain/repositories/status_repository.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';
import '../services/month_presence.dart';

/// The current [month], [today] and the soldier's parade state on each day.
typedef MonthReport = ({
  DateTime month,
  DateTime today,
  MonthPresence presence,
});

/// This month's presence for one soldier, from the soldier's own attendance
/// records and statuses, re-read against the clock on every change.
class WatchMonthPresence implements StreamUseCase<MonthReport, Soldier> {
  const WatchMonthPresence(this._attendance, this._statuses, this._clock);

  final AttendanceRepository _attendance;
  final StatusRepository _statuses;
  final Clock _clock;

  @override
  ResultStream<MonthReport> call(Soldier soldier) => Rx.combineLatest2(
        _attendance.watchForSoldier(soldier.id),
        _statuses.watchForSoldier(soldier.id),
        (Either<Failure, List<AttendanceRecord>> records,
                Either<Failure, List<Status>> statuses) =>
            records.flatMap((records) => statuses.map((statuses) {
                  final now = _clock.now();
                  final month = DateTime(now.year, now.month);
                  return (
                    month: month,
                    today: now,
                    presence: monthPresence(
                      soldier: soldier,
                      records: records,
                      statuses: statuses,
                      month: month,
                      now: now,
                    ),
                  );
                })),
      );
}

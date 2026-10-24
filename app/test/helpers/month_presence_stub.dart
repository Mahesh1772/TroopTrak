import 'package:dartz/dartz.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/error/result.dart';
import 'package:trooptrak_final_application/features/attendance/domain/services/month_presence.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/watch_month_presence.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_state.dart';

/// July 2023 up to the helpers' fixed clock (the 5th): three days in camp, a
/// leave and a medical appointment.
MonthReport buildMonthReport({List<ParadeState?>? days}) => (
      month: DateTime(2023, 7),
      today: DateTime(2023, 7, 5, 9),
      presence: MonthPresence(days ??
          [
            ParadeState.inCamp,
            ParadeState.inCamp,
            ParadeState.leave,
            ParadeState.medical,
            ParadeState.inCamp,
            ...List<ParadeState?>.filled(26, null),
          ]),
    );

class StubWatchMonthPresence implements WatchMonthPresence {
  StubWatchMonthPresence([MonthReport? report])
      : result = Right(report ?? buildMonthReport());

  StubWatchMonthPresence.failing(Failure failure) : result = Left(failure);

  final Either<Failure, MonthReport> result;

  @override
  ResultStream<MonthReport> call(Soldier soldier) => Stream.value(result);
}

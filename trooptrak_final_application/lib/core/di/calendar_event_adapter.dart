import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import '../../features/conducts/domain/entities/conduct.dart';
import '../../features/conducts/domain/repositories/conduct_repository.dart';
import '../../features/dashboard/domain/entities/calendar_event.dart';
import '../../features/dashboard/domain/repositories/calendar_event_source.dart';
import '../../features/guard_duty/domain/entities/duty.dart';
import '../../features/guard_duty/domain/repositories/duty_repository.dart';
import '../error/failures.dart';
import '../error/result.dart';

/// Feeds the dashboard calendar from conducts (by type) and guard duties.
class CalendarEventAdapter implements CalendarEventSource {
  const CalendarEventAdapter(this._conducts, this._duties);

  final ConductRepository _conducts;
  final DutyRepository _duties;

  @override
  ResultStream<List<CalendarEvent>> watch() => Rx.combineLatest2(
        _conducts.watchAll(),
        _duties.watchAll(),
        (Either<Failure, List<Conduct>> conducts,
                Either<Failure, List<Duty>> duties) =>
            conducts.flatMap((c) => duties.map((d) => [
                  for (final x in c)
                    CalendarEvent(
                      title: x.type,
                      start: x.start,
                      end: CalendarEvent.endFor(x.start, x.end),
                      kind: CalendarEventKind.conduct,
                    ),
                  for (final x in d)
                    CalendarEvent(
                      title: 'Guard Duty',
                      start: x.start,
                      end: CalendarEvent.endFor(x.start, x.end),
                      kind: CalendarEventKind.guardDuty,
                    ),
                ])),
      );
}

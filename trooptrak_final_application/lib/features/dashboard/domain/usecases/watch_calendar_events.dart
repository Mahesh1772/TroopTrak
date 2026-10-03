import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/calendar_event.dart';
import '../repositories/calendar_event_source.dart';

class WatchCalendarEvents
    implements StreamUseCase<List<CalendarEvent>, NoParams> {
  const WatchCalendarEvents(this._source);

  final CalendarEventSource _source;

  @override
  ResultStream<List<CalendarEvent>> call(NoParams params) => _source.watch();
}

/// Events on [day], earliest first.
List<CalendarEvent> eventsOn(Iterable<CalendarEvent> events, DateTime day) => [
      for (final e in events)
        if (e.day == DateTime(day.year, day.month, day.day)) e,
    ]..sort((a, b) => a.start.compareTo(b.start));

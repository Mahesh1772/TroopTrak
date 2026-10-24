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

/// Events on [day], earliest first; a tie goes to conducts, then by title.
List<CalendarEvent> eventsOn(Iterable<CalendarEvent> events, DateTime day) => [
      for (final e in events)
        if (e.day == DateTime(day.year, day.month, day.day)) e,
    ]..sort((a, b) {
        final byStart = a.start.compareTo(b.start);
        if (byStart != 0) return byStart;
        final byKind = a.kind.index.compareTo(b.kind.index);
        return byKind != 0 ? byKind : a.title.compareTo(b.title);
      });

/// The kinds that have an event on [day], in legend order.
List<CalendarEventKind> dotKindsOn(
    Iterable<CalendarEvent> events, DateTime day) {
  final present = {for (final e in eventsOn(events, day)) e.kind};
  return [
    for (final kind in CalendarEventKind.values)
      if (present.contains(kind)) kind,
  ];
}

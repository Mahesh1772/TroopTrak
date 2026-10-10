import '../../../../core/error/result.dart';
import '../entities/calendar_event.dart';

/// Conducts and guard duties as calendar entries. Implemented by the
/// composition root, so the dashboard never imports those features.
abstract interface class CalendarEventSource {
  ResultStream<List<CalendarEvent>> watch();
}

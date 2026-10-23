import '../../../../core/services/clock.dart';
import '../../../../core/state/stream_state_notifier.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/strength_summary.dart';
import '../../domain/services/month_grid.dart';
import '../../domain/usecases/watch_calendar_events.dart';
import '../../domain/usecases/watch_strength_summary.dart';

class StrengthProvider extends StreamStateNotifier<StrengthSummary> {
  StrengthProvider(WatchStrengthSummary watch, this._clock)
      : super(watch(const NoParams()));

  final Clock _clock;

  /// "As of" stamp for the strength card (R1 dashboard format).
  String get stamp => formatDashboardStamp(_clock.now());
}

/// Month grid with conducts and guard duties (the source's Syncfusion
/// calendar on the back of the flip card).
class EventCalendarProvider extends StreamStateNotifier<List<CalendarEvent>> {
  EventCalendarProvider(WatchCalendarEvents watch, this._clock)
      : _selected = dateOnly(_clock.now()),
        super(watch(const NoParams())) {
    _month = DateTime(_selected.year, _selected.month);
  }

  final Clock _clock;
  DateTime _selected;
  late DateTime _month;

  DateTime get today => dateOnly(_clock.now());
  DateTime get selected => _selected;
  DateTime get month => _month;

  List<List<MonthCell>> get weeks => monthWeeks(_month);

  List<CalendarEvent> get selectedEvents => on(_selected);

  List<CalendarEvent> on(DateTime day) =>
      eventsOn(state.dataOrNull ?? const [], day);

  List<CalendarEventKind> kindsOn(DateTime day) =>
      dotKindsOn(state.dataOrNull ?? const [], day);

  void select(DateTime day) {
    _selected = dateOnly(day);
    notifyListeners();
  }

  void shiftMonth(int delta) {
    _month = DateTime(_month.year, _month.month + delta);
    notifyListeners();
  }
}

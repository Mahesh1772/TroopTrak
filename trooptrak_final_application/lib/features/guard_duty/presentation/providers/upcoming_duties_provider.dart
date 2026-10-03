import '../../../../core/services/clock.dart';
import '../../../../core/state/stream_state_notifier.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/duty.dart';
import '../../domain/usecases/duty_usecases.dart';

/// R14a: duties on the selected day, and those from the next day on.
class UpcomingDutiesProvider extends StreamStateNotifier<List<Duty>> {
  UpcomingDutiesProvider({
    required WatchDuties watch,
    required DeleteDuty delete,
    required Clock clock,
  })  : _delete = delete,
        today = dateOnly(clock.now()),
        super(watch(const NoParams())) {
    _selected = today;
  }

  final DeleteDuty _delete;
  final DateTime today;
  late DateTime _selected;

  DateTime get selected => _selected;

  void select(DateTime day) {
    _selected = dateOnly(day);
    notifyListeners();
  }

  List<Duty> _where(bool Function(int diff) keep) => [
        for (final d in state.dataOrNull ?? const <Duty>[])
          if (keep(dayDifference(d.day, _selected))) d,
      ]..sort((a, b) => a.start.compareTo(b.start));

  List<Duty> get onSelectedDay => _where((diff) => diff == 0);

  List<Duty> get upcoming => _where((diff) => diff >= 1);

  /// R9; returns null on success, otherwise the message to show.
  Future<String?> delete(Duty duty) async =>
      (await _delete(duty)).fold((f) => f.message, (_) => null);
}

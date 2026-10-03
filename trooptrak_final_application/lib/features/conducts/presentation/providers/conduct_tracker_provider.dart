import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/services/clock.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../soldiers/domain/usecases/soldier_usecases.dart';
import '../../domain/entities/conduct.dart';
import '../../domain/usecases/conduct_usecases.dart';

typedef ParticipationBar = ({String label, int participants});

/// Conducts on the selected day (R13) and the unit strength for the chart.
class ConductTrackerProvider extends ChangeNotifier {
  ConductTrackerProvider({
    required WatchConductsOnDay watchOnDay,
    required WatchSoldiers watchSoldiers,
    required Clock clock,
  })  : _watchOnDay = watchOnDay,
        today = dateOnly(clock.now()) {
    _day = today;
    _listen();
    _soldiers = watchSoldiers(const NoParams()).listen((r) {
      _strength = r.fold((_) => _strength, (all) => all.length);
      notifyListeners();
    });
  }

  final WatchConductsOnDay _watchOnDay;
  final DateTime today;
  late DateTime _day;
  ViewState<List<Conduct>> _conducts = const ViewLoading();
  int _strength = 0;
  StreamSubscription<Object?>? _subscription;
  late final StreamSubscription<Object?> _soldiers;

  DateTime get day => _day;
  ViewState<List<Conduct>> get conducts => _conducts;

  /// Strip and calendar range: the source's 2022 start to a year from today.
  DateTime get firstDay => DateTime(2022);
  DateTime get lastDay => DateTime(today.year + 1, today.month, today.day);

  /// K20 fix: bars are measured against unit strength, never below the tallest.
  double get chartMax {
    final tallest =
        bars.fold(0, (m, b) => b.participants > m ? b.participants : m);
    return (_strength > tallest ? _strength : tallest).toDouble();
  }

  List<ParticipationBar> get bars => [
        for (final c in _conducts.dataOrNull ?? const <Conduct>[])
          (label: c.name, participants: c.participants.length),
      ];

  void selectDay(DateTime day) {
    if (isSameDay(day, _day)) return;
    _day = dateOnly(day);
    _conducts = const ViewLoading();
    _listen();
    notifyListeners();
  }

  void _listen() {
    unawaited(_subscription?.cancel());
    _subscription = _watchOnDay(_day).listen((r) {
      _conducts = r.fold((f) => ViewError(f), (d) => ViewData(d));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_soldiers.cancel());
    super.dispose();
  }
}

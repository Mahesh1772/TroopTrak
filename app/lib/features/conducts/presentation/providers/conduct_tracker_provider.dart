import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/services/clock.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/usecases/soldier_usecases.dart';
import '../../domain/entities/conduct.dart';
import '../../domain/services/participation_ticks.dart';
import '../../domain/usecases/conduct_usecases.dart';

/// Conducts on the selected day (R13) and the roster they are measured against.
/// [participant] is the signed-in soldier's name on the soldier side.
class ConductTrackerProvider extends ChangeNotifier {
  ConductTrackerProvider({
    required WatchConductsOnDay watchOnDay,
    required WatchSoldiers watchSoldiers,
    required Clock clock,
    String? participant,
  })  : _watchOnDay = watchOnDay,
        _participant = participant,
        today = dateOnly(clock.now()) {
    _day = today;
    _listen();
    _soldiers = watchSoldiers(const NoParams()).listen((r) {
      _roster = r.fold((_) => _roster, (all) => all);
      notifyListeners();
    });
  }

  final WatchConductsOnDay _watchOnDay;
  final String? _participant;
  final DateTime today;
  late DateTime _day;
  ViewState<List<Conduct>> _conducts = const ViewLoading();
  List<Soldier> _roster = const [];
  StreamSubscription<Object?>? _subscription;
  late final StreamSubscription<Object?> _soldiers;

  DateTime get day => _day;
  ViewState<List<Conduct>> get conducts => _conducts;
  List<Soldier> get roster => _roster;

  /// Strip and calendar range: the source's 2022 start to a year from today.
  DateTime get firstDay => DateTime(2022);
  DateTime get lastDay => DateTime(today.year + 1, today.month, today.day);

  /// R13 soldier marker; null when nobody is tracked (commander side).
  bool? isParticipating(Conduct conduct) {
    final name = _participant;
    return name == null ? null : conduct.includes(name);
  }

  ParticipationTicks ticksFor(Conduct conduct) => participationTicks(
        roster: _roster,
        conduct: conduct,
        selfName: _participant,
      );

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

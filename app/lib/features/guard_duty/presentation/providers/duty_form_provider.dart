import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/state/view_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/entities/duty.dart';
import '../../domain/services/duty_points.dart';
import '../../domain/usecases/duty_usecases.dart';

/// Add / update duty form: date (prices the duty, R7), times and up to ten
/// eligible participants (R6, R10a).
class DutyFormProvider extends ChangeNotifier {
  DutyFormProvider({
    required GetDutyRoster roster,
    required AddDuty add,
    required UpdateDuty update,
    this.initial,
  })  : _add = add,
        _update = update {
    final d = initial;
    if (d != null) {
      _date = d.day;
      _start = TimeOfDay.fromDateTime(d.start);
      _end = TimeOfDay.fromDateTime(d.end);
      _participants = {...d.participants};
    }
    unawaited(_load(roster));
  }

  final AddDuty _add;
  final UpdateDuty _update;
  final Duty? initial;

  ViewState<DutyRoster> _roster = const ViewLoading();
  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  Map<String, String> _participants = {};
  String _query = '';
  bool _saving = false;
  bool _disposed = false;

  bool get isUpdate => initial != null;
  ViewState<DutyRoster> get roster => _roster;
  DateTime? get date => _date;
  TimeOfDay? get start => _start;
  TimeOfDay? get end => _end;
  Map<String, String> get participants => Map.unmodifiable(_participants);
  bool get saving => _saving;
  String get query => _query;

  DayPoints get pricing => DutyPoints.forDate(_date);

  List<Soldier> get searchResults {
    final all = _roster.dataOrNull?.soldiers ?? const <Soldier>[];
    final q = _query.toLowerCase();
    return [
      for (final s in all)
        if (q.isEmpty || s.name.toLowerCase().contains(q)) s,
    ];
  }

  bool canServe(Soldier s) => _roster.dataOrNull?.canServe(s) ?? false;

  bool isOnDuty(Soldier s) => _participants.containsKey(s.name);

  void setDate(DateTime date) => _set(() => _date = dateOnly(date));
  void setStart(TimeOfDay time) => _set(() => _start = time);
  void setEnd(TimeOfDay time) => _set(() => _end = time);
  void search(String query) => _set(() => _query = query);

  /// Returns null when toggled, otherwise why not (ineligible or full).
  String? toggle(Soldier s) {
    if (isOnDuty(s)) {
      _set(() => _participants.remove(s.name));
      return null;
    }
    if (!canServe(s)) return '${s.name} is ineligible for guard duty.';
    if (_participants.length >= Duty.maxSlots) return tooManySlots;
    _set(() => _participants[s.name] = s.rank);
    return null;
  }

  Future<void> _load(GetDutyRoster roster) async {
    final result = await roster(const NoParams());
    if (_disposed) return;
    _set(() => _roster = result.fold((f) => ViewError(f), (r) => ViewData(r)));
  }

  void _set(VoidCallback change) {
    change();
    notifyListeners();
  }

  /// Returns null on success, otherwise the message to show. The form checks
  /// that the date and both times are set first.
  Future<String?> submit() async {
    DateTime at(TimeOfDay t) =>
        DateTime(_date!.year, _date!.month, _date!.day, t.hour, t.minute);
    final duty = Duty(
      id: initial?.id ?? '',
      start: at(_start!),
      end: at(_end!),
      dayType: pricing.dayType,
      points: pricing.points,
      participants: {..._participants},
    );
    _set(() => _saving = true);
    final result = await (isUpdate
        ? _update(UpdateDutyParams(previous: initial!, updated: duty))
        : _add(duty));
    if (!_disposed) _set(() => _saving = false);
    return result.fold((f) => f.message, (_) => null);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/state/view_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/usecases/soldier_usecases.dart';
import '../../domain/entities/conduct.dart';
import '../../domain/usecases/build_conduct_roster.dart';
import '../../domain/usecases/conduct_usecases.dart';

/// Add / update conduct form state. Adding builds the R5 roster on open and on
/// every type change; updating keeps the stored participants and reasons.
class ConductFormProvider extends ChangeNotifier {
  ConductFormProvider({
    required WatchSoldiers watchSoldiers,
    required BuildConductRoster buildRoster,
    required AddConduct add,
    required UpdateConduct update,
    this.initial,
  })  : _buildRoster = buildRoster,
        _add = add,
        _update = update {
    final c = initial;
    if (c != null) {
      _type = c.type;
      _date = c.day;
      _start = TimeOfDay.fromDateTime(c.start);
      _end = TimeOfDay.fromDateTime(c.end);
      _participants = [...c.participants];
      _reasons = {...c.soldierReason};
    } else {
      unawaited(_rebuildRoster());
    }
    _soldierSub = watchSoldiers(const NoParams()).listen((r) {
      _soldiers = r.fold((f) => ViewError(f), (d) => ViewData(d));
      notifyListeners();
    });
  }

  final BuildConductRoster _buildRoster;
  final AddConduct _add;
  final UpdateConduct _update;
  final Conduct? initial;
  late final StreamSubscription<Object?> _soldierSub;

  ViewState<List<Soldier>> _soldiers = const ViewLoading();
  String? _type;
  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  List<String> _participants = [];
  Map<String, String> _reasons = {};
  String _query = '';
  bool _saving = false;
  String? _rosterError;
  bool _disposed = false;

  bool get isUpdate => initial != null;
  ViewState<List<Soldier>> get soldiers => _soldiers;
  String? get type => _type;
  DateTime? get date => _date;
  TimeOfDay? get start => _start;
  TimeOfDay? get end => _end;
  List<String> get participants => List.unmodifiable(_participants);
  bool get saving => _saving;
  String? get rosterError => _rosterError;
  String get query => _query;

  /// Soldiers matching the name search, in Users order.
  List<Soldier> get visibleSoldiers {
    final all = _soldiers.dataOrNull ?? const <Soldier>[];
    final q = _query.toLowerCase();
    return [
      for (final s in all)
        if (q.isEmpty || s.name.toLowerCase().contains(q)) s,
    ];
  }

  bool isParticipating(String name) => _participants.contains(name);

  /// Why a soldier is out: their status (R5) or "Removed from conduct".
  String? reasonFor(String name) =>
      isParticipating(name) ? null : (_reasons[name] ?? Conduct.removedReason);

  void setType(String? type) {
    if (type == _type) return;
    _type = type;
    notifyListeners();
    if (!isUpdate) unawaited(_rebuildRoster());
  }

  void setDate(DateTime date) => _set(() => _date = dateOnly(date));
  void setStart(TimeOfDay time) => _set(() => _start = time);
  void setEnd(TimeOfDay time) => _set(() => _end = time);
  void search(String query) => _set(() => _query = query);

  void toggle(String name) => _set(() => isParticipating(name)
      ? _participants.remove(name)
      : _participants.add(name));

  void _set(VoidCallback change) {
    change();
    notifyListeners();
  }

  Future<void> _rebuildRoster() async {
    final requested = _type;
    final result = await _buildRoster(requested ?? '');
    if (_disposed || requested != _type) return;
    result.fold((f) => _rosterError = f.message, (roster) {
      _rosterError = null;
      _participants = [...roster.participants];
      _reasons = {...roster.reasons};
    });
    notifyListeners();
  }

  /// Returns null on success, otherwise the message to show. The form checks
  /// that type, date and both times are set before calling this (K21).
  Future<String?> submit(String name) async {
    DateTime at(TimeOfDay t) =>
        DateTime(_date!.year, _date!.month, _date!.day, t.hour, t.minute);
    final conduct = Conduct(
      id: initial?.id ?? '',
      name: name,
      type: _type!,
      start: at(_start!),
      end: at(_end!),
      participants: [..._participants],
      soldierReason: {..._reasons},
    );
    _set(() => _saving = true);
    final result = await (isUpdate ? _update(conduct) : _add(conduct));
    _set(() => _saving = false);
    return result.fold((f) => f.message, (_) => null);
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_soldierSub.cancel());
    super.dispose();
  }
}

import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/repositories/soldier_repository.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

/// R21: every soldier with `isInCamp` set to the effective value, i.e. their
/// latest visible attendance record, or the stored `currentAttendance` if none.
List<Soldier> withEffectivePresence(
  Iterable<Soldier> soldiers,
  Iterable<AttendanceRecord> records,
  DateTime now,
) {
  final bySoldier = <String, List<AttendanceRecord>>{};
  for (final r in records) {
    (bySoldier[r.soldierId] ??= []).add(r);
  }
  return [
    for (final s in soldiers)
      s.copyWith(
        isInCamp: effectiveInCamp(bySoldier[s.id] ?? const [], now,
            fallback: s.isInCamp),
      ),
  ];
}

/// Soldiers and all attendance combined in the domain, not in a widget.
class WatchSoldiersInCamp implements StreamUseCase<List<Soldier>, NoParams> {
  const WatchSoldiersInCamp(this._soldiers, this._attendance, this._clock);

  final SoldierRepository _soldiers;
  final AttendanceRepository _attendance;
  final Clock _clock;

  @override
  ResultStream<List<Soldier>> call(NoParams params) => Rx.combineLatest2(
        _soldiers.watchAll(),
        _attendance.watchAll(),
        (Either<Failure, List<Soldier>> soldiers,
                Either<Failure, List<AttendanceRecord>> records) =>
            soldiers.flatMap((s) =>
                records.map((r) => withEffectivePresence(s, r, _clock.now()))),
      );
}

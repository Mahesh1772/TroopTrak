import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../attendance/domain/usecases/watch_soldiers_in_camp.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../statuses/domain/entities/status.dart';
import '../../../statuses/domain/repositories/status_repository.dart';
import '../entities/strength_summary.dart';

/// Soldiers (with effective in-camp) and every status, combined live.
class WatchStrengthSummary implements StreamUseCase<StrengthSummary, NoParams> {
  const WatchStrengthSummary(this._soldiers, this._statuses, this._clock);

  final WatchSoldiersInCamp _soldiers;
  final StatusRepository _statuses;
  final Clock _clock;

  @override
  ResultStream<StrengthSummary> call(NoParams params) => Rx.combineLatest2(
        _soldiers(const NoParams()),
        _statuses.watchAll(),
        (Either<Failure, List<Soldier>> soldiers,
                Either<Failure, List<Status>> statuses) =>
            soldiers.flatMap((all) => statuses
                .map((s) => buildStrengthSummary(all, s, _clock.now()))),
      );
}

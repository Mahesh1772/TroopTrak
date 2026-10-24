import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../statuses/domain/entities/status.dart';
import '../../../statuses/domain/repositories/status_repository.dart';
import '../../../statuses/domain/services/parade_roster.dart';
import 'watch_soldiers_in_camp.dart';

/// Every soldier with effective presence and current statuses, combined live.
class WatchParadeRoster implements StreamUseCase<List<ParadeEntry>, NoParams> {
  const WatchParadeRoster(this._soldiers, this._statuses, this._clock);

  final WatchSoldiersInCamp _soldiers;
  final StatusRepository _statuses;
  final Clock _clock;

  @override
  ResultStream<List<ParadeEntry>> call(NoParams params) => Rx.combineLatest2(
        _soldiers(const NoParams()),
        _statuses.watchAll(),
        (Either<Failure, List<Soldier>> soldiers,
                Either<Failure, List<Status>> statuses) =>
            soldiers.flatMap((all) =>
                statuses.map((s) => paradeRoster(all, s, _clock.now()))),
      );
}

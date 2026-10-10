import '../../../../core/services/clock.dart';
import '../../../../core/state/stream_state_notifier.dart';
import '../../../statuses/domain/entities/status.dart';
import '../../../statuses/domain/usecases/status_usecases.dart';

typedef StatusSplit = ({List<Status> active, List<Status> past});

class StatusesProvider extends StreamStateNotifier<List<Status>> {
  StatusesProvider({
    required WatchSoldierStatuses watch,
    required DeleteStatus delete,
    required Clock clock,
    required this.soldierId,
  })  : _delete = delete,
        _clock = clock,
        super(watch(soldierId));

  final DeleteStatus _delete;
  final Clock _clock;
  final String soldierId;

  /// R2 split for the tab, recomputed against the current day.
  StatusSplit? get split {
    final all = state.dataOrNull;
    return all == null ? null : partitionStatuses(all, _clock.now());
  }

  /// Returns null on success, otherwise the message to show.
  Future<String?> delete(Status status) async =>
      (await _delete(status)).fold((f) => f.message, (_) => null);
}

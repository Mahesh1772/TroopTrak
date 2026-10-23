import '../../../../core/state/stream_state_notifier.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/usecases/soldier_usecases.dart';

/// The signed-in commander's own rank, for the app bar avatar.
class CommanderRankProvider extends StreamStateNotifier<Soldier> {
  CommanderRankProvider(WatchSoldier watch, String? id)
      : super(id == null || id.isEmpty ? const Stream.empty() : watch(id));

  String? get rank => state.dataOrNull?.rank;
}

import '../../../../core/state/stream_state_notifier.dart';
import '../../../soldiers/domain/entities/soldier.dart';

/// The profile being shown. The source stream differs per role: `Users/{id}`
/// for commanders, the soldier's own `Men/{uid}` record on the soldier side.
class SoldierProfileProvider extends StreamStateNotifier<Soldier> {
  SoldierProfileProvider(super.stream);
}

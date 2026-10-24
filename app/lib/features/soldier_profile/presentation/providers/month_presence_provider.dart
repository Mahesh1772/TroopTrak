import '../../../../core/state/stream_state_notifier.dart';
import '../../../attendance/domain/usecases/watch_month_presence.dart';
import '../../../soldiers/domain/entities/soldier.dart';

/// This month's parade state for the soldier on the profile.
class MonthPresenceProvider extends StreamStateNotifier<MonthReport> {
  MonthPresenceProvider({
    required WatchMonthPresence watch,
    required Soldier soldier,
  }) : super(watch(soldier));
}

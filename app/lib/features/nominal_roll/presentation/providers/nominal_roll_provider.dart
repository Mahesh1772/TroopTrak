import '../../../../core/state/stream_state_notifier.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../attendance/domain/usecases/attendance_usecases.dart';
import '../../../attendance/domain/usecases/watch_parade_roster.dart';
import '../../../statuses/domain/services/parade_roster.dart';
import '../../domain/entities/nominal_roll.dart';
import '../../domain/services/roster_filter.dart';

class NominalRollProvider extends StreamStateNotifier<NominalRoll> {
  /// [excludeId] is the signed-in commander's `Users` id (their display
  /// name), hidden from the roll (R12).
  NominalRollProvider({
    required WatchParadeRoster watch,
    required BookInOut bookInOut,
    String? excludeId,
  })  : _bookInOut = bookInOut,
        super(watch(const NoParams()).map((result) => result
            .map((entries) => NominalRoll(entries, excludeId: excludeId))));

  final BookInOut _bookInOut;

  String _query = '';
  SearchCategory _category = SearchCategory.name;

  String get query => _query;
  SearchCategory get category => _category;

  /// Empty while loading or on error; see [state].
  List<ParadeEntry> get visible => switch (state) {
        ViewData(:final data) => data.search(_query, _category),
        _ => const [],
      };

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  /// Chips are single-select and one is always on, Name by default.
  void selectCategory(SearchCategory category) {
    _category = category;
    notifyListeners();
  }

  /// R10; returns null on success, otherwise the message to show.
  Future<String?> setInCamp(String soldierId, bool isInCamp) async =>
      (await _bookInOut(BookInOutParams(soldierId, isInsideCamp: isInCamp)))
          .fold((f) => f.message, (_) => null);
}

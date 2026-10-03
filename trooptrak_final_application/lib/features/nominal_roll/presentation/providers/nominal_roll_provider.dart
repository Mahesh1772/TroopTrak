import '../../../../core/state/stream_state_notifier.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../attendance/domain/usecases/attendance_usecases.dart';
import '../../../attendance/domain/usecases/watch_soldiers_in_camp.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/services/roster_filter.dart';

class NominalRollProvider extends StreamStateNotifier<List<Soldier>> {
  NominalRollProvider({
    required WatchSoldiersInCamp watch,
    required BookInOut bookInOut,
    this.excludeId,
  })  : _bookInOut = bookInOut,
        super(watch(const NoParams()));

  final BookInOut _bookInOut;

  /// The signed-in commander's `Users` id (their display name), hidden (R12).
  final String? excludeId;

  String _query = '';
  SearchCategory _category = SearchCategory.name;

  String get query => _query;
  SearchCategory get category => _category;

  /// Null while loading or on error; see [state].
  List<Soldier>? get visible => switch (state) {
        ViewData(:final data) => filterRoster(data,
            query: _query, category: _category, excludeId: excludeId),
        _ => null,
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
  Future<String?> setInCamp(Soldier soldier, bool isInCamp) async =>
      (await _bookInOut(BookInOutParams(soldier.id, isInsideCamp: isInCamp)))
          .fold((f) => f.message, (_) => null);
}

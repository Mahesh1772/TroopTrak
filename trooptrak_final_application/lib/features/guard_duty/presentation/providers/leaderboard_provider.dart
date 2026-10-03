import '../../../../core/constants/ranks.dart';
import '../../../../core/state/stream_state_notifier.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/usecases/soldier_usecases.dart';

enum LeaderboardColumn { rank, name, points }

/// D3: every soldier's `Users.points`, sortable on each column and searchable
/// by name (replaces the source's Syncfusion grid).
class LeaderboardProvider extends StreamStateNotifier<List<Soldier>> {
  LeaderboardProvider(WatchSoldiers watch) : super(watch(const NoParams()));

  LeaderboardColumn _column = LeaderboardColumn.points;
  bool _ascending = false;
  String _query = '';

  LeaderboardColumn get column => _column;
  bool get ascending => _ascending;

  /// Tapping the sorted column flips it; a new column starts with points
  /// highest first and the others A→Z / most senior first.
  void sortBy(LeaderboardColumn column) {
    _ascending =
        column == _column ? !_ascending : column != LeaderboardColumn.points;
    _column = column;
    notifyListeners();
  }

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  List<Soldier>? get rows {
    final all = state.dataOrNull;
    if (all == null) return null;
    final q = _query.toLowerCase();
    final rows = [
      for (final s in all)
        if (q.isEmpty || s.name.toLowerCase().contains(q)) s,
    ]..sort(_compare);
    return _ascending ? rows : rows.reversed.toList();
  }

  int _compare(Soldier a, Soldier b) => switch (_column) {
        LeaderboardColumn.points => a.points.compareTo(b.points),
        LeaderboardColumn.name =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        LeaderboardColumn.rank =>
          _seniority(b.rank).compareTo(_seniority(a.rank)),
      };

  static int _seniority(String rank) => Ranks.all.indexOf(rank.toUpperCase());
}

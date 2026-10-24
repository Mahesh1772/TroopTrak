import '../../../../core/constants/ranks.dart';
import '../../../../core/state/stream_state_notifier.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/usecases/soldier_usecases.dart';
import '../../domain/services/leaderboard.dart';

enum LeaderboardColumn { rank, name, points }

/// D3: every soldier's `Users.points`, sortable on each column and searchable
/// by name (replaces the source's Syncfusion grid). [selfName] is the signed-in
/// soldier's name on the soldier side; the commander has no row of their own.
class LeaderboardProvider extends StreamStateNotifier<List<Soldier>> {
  LeaderboardProvider(WatchSoldiers watch, {String? selfName})
      : _selfName = selfName,
        super(watch(const NoParams()));

  final String? _selfName;
  double _top = 0;
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

  @override
  void onData(ViewState<List<Soldier>> state) =>
      _top = Leaderboard.topPoints(state.dataOrNull ?? const <Soldier>[]);

  /// Length of [soldier]'s points bar, 0 to 1 of the top score on the roster
  /// (not just the rows a search leaves).
  double barFraction(Soldier soldier) =>
      Leaderboard.barFraction(soldier.points, _top);

  bool isSelf(Soldier soldier) => Leaderboard.isSelf(soldier, _selfName);

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

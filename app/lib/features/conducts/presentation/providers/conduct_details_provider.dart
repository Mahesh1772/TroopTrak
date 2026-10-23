import '../../../../core/state/stream_state_notifier.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/usecases/conduct_usecases.dart';
import '../../domain/usecases/watch_conduct_breakdown.dart';

class ConductDetailsProvider extends StreamStateNotifier<ConductBreakdown> {
  ConductDetailsProvider({
    required WatchConductBreakdown watch,
    required DeleteConduct delete,
    required this.conductId,
  })  : _delete = delete,
        super(watch(conductId));

  final DeleteConduct _delete;
  final String conductId;
  String _query = '';
  ConductGroup _group = ConductGroup.participants;

  String get query => _query;

  ConductGroup get group => _group;

  /// The breakdown narrowed by the search.
  ConductBreakdown? get visible => state.dataOrNull?.search(_query);

  /// The searched soldiers of the selected group.
  List<Soldier> get rows => visible?.members(_group) ?? const [];

  void select(ConductGroup group) {
    _group = group;
    notifyListeners();
  }

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  /// Returns null on success, otherwise the message to show.
  Future<String?> delete() async =>
      (await _delete(conductId)).fold((f) => f.message, (_) => null);
}

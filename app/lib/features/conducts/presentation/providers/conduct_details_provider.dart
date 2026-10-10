import '../../../../core/state/stream_state_notifier.dart';
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

  String get query => _query;

  ConductBreakdown? get visible => state.dataOrNull?.search(_query);

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  /// Returns null on success, otherwise the message to show.
  Future<String?> delete() async =>
      (await _delete(conductId)).fold((f) => f.message, (_) => null);
}

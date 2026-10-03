import '../../../../core/state/stream_state_notifier.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../../../attendance/domain/usecases/attendance_usecases.dart';

/// R11 list for one soldier (newest first, future records hidden).
class AttendanceProvider extends StreamStateNotifier<List<AttendanceRecord>> {
  AttendanceProvider({
    required WatchAttendance watch,
    required DeleteAttendance delete,
    required String soldierId,
  })  : _delete = delete,
        super(watch(soldierId));

  final DeleteAttendance _delete;

  /// Returns null on success, otherwise the message to show.
  Future<String?> delete(AttendanceRecord record) async =>
      (await _delete(record)).fold((f) => f.message, (_) => null);
}

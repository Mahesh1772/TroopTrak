import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/data/firestore_helpers.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/status.dart';

abstract final class StatusModel {
  static final _unparseable = DateTime(1970);

  static Status fromMap(String soldierId, String id, Map<String, dynamic> map) {
    final startId = map[StatusFields.startAttendanceId];
    final endId = map[StatusFields.endAttendanceId];
    return Status(
      id: id,
      soldierId: soldierId,
      type: readString(map[StatusFields.statusType]),
      name: readString(map[StatusFields.statusName]),
      start: parseDay(map[StatusFields.startDate]?.toString()) ?? _unparseable,
      end: parseDay(map[StatusFields.endDate]?.toString()) ?? _unparseable,
      startAttendanceId:
          startId is String && startId.isNotEmpty ? startId : null,
      endAttendanceId: endId is String && endId.isNotEmpty ? endId : null,
    );
  }

  static Map<String, dynamic> toMap(Status status) => {
        StatusFields.statusName: status.name,
        StatusFields.statusType: status.type,
        StatusFields.startDate: formatDay(status.start),
        StatusFields.endDate: formatDay(status.end),
        StatusFields.startAttendanceId: attendanceDocId(status.bookOutAt),
        StatusFields.endAttendanceId: attendanceDocId(status.bookInAt),
      };

  /// Linked attendance doc ids to remove; falls back to the computed ids.
  static List<String> linkedIds(Status status) => status.isExcuse
      ? const []
      : [
          status.startAttendanceId ?? attendanceDocId(status.bookOutAt),
          status.endAttendanceId ?? attendanceDocId(status.bookInAt),
        ];
}

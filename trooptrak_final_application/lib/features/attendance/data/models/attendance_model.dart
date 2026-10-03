import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/attendance_record.dart';

abstract final class AttendanceModel {
  static AttendanceRecord fromMap(
    String soldierId,
    String id,
    Map<String, dynamic> map,
  ) =>
      AttendanceRecord(
        id: id,
        soldierId: soldierId,
        isInsideCamp: map[AttendanceFields.isInsideCamp] == true,
        timestamp: parseAttendanceDisplay(
                map[AttendanceFields.dateTime]?.toString()) ??
            parseAttendanceDocId(id) ??
            DateTime(1970),
      );

  static Map<String, dynamic> toMap(AttendanceRecord record) => {
        AttendanceFields.isInsideCamp: record.isInsideCamp,
        AttendanceFields.dateTime: attendanceDisplay(record.timestamp),
      };
}

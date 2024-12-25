import '../../domain/entities/attendance_record.dart';
import 'package:intl/intl.dart';

class AttendanceModel extends AttendanceRecord {
  static final DateFormat standardFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  AttendanceModel({
    required super.id,
    required super.dateTime,
    required super.isInsideCamp,
  });

  factory AttendanceModel.fromJson(String id, Map<String, dynamic> json) {
    return AttendanceModel(
      id: id,
      dateTime: json['date&time'],
      isInsideCamp: json['isInsideCamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date&time': dateTime,
      'isInsideCamp': isInsideCamp,
    };
  }
}

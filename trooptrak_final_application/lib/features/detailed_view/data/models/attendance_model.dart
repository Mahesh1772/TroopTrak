import '../../domain/entities/attendance_record.dart';

class AttendanceModel extends AttendanceRecord {
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

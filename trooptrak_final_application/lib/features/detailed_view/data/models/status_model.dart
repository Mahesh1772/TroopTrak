// import '../../domain/entities/status.dart';

// class StatusModel extends Status {
//   StatusModel({
//     required super.id,
//     required super.statusType,
//     required super.statusName,
//     required super.startDate,
//     required super.endDate,
//     required super.startId,
//     required super.endId,
//   });

//   factory StatusModel.fromJson(Map<String, dynamic> json) {
//     return StatusModel(
//       id: json['id'] ?? '',
//       statusType: json['statusType'] ?? '',
//       statusName: json['statusName'] ?? '',
//       startDate: json['startDate'] ?? '',
//       endDate: json['endDate'] ?? '',
//       startId: json['start_id'] ?? '',
//       endId: json['end_id'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'statusType': statusType,
//       'statusName': statusName,
//       'startDate': startDate,
//       'endDate': endDate,
//       'start_id': startId,
//       'end_id': endId,
//     };
//   }
// }
import '../../domain/entities/status.dart';

class StatusModel extends Status {
  StatusModel({
    required super.id,
    required super.statusType,
    required super.statusName,
    required super.startId,
    required super.endId,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'] ?? '',
      statusType: json['statusType'] ?? '',
      statusName: json['statusName'] ?? '',
      startId: json['start_id'] ?? '',
      endId: json['end_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusType': statusType,
      'statusName': statusName,
      'start_id': startId,
      'end_id': endId,
    };
  }
}
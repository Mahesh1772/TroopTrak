import '../../domain/entities/status.dart';

class StatusModel extends Status {
  StatusModel({
    required String id,
    required String statusType,
    required String statusName,
    required String startDate,
    required String endDate,
    required String startId,
    required String endId,
  }) : super(
          id: id,
          statusType: statusType,
          statusName: statusName,
          startDate: startDate,
          endDate: endDate,
          startId: startId,
          endId: endId,
        );

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['ID'] ?? '',
      statusType: json['statusType'] ?? '',
      statusName: json['statusName'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      startId: json['start_id'] ?? '',
      endId: json['end_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusType': statusType,
      'statusName': statusName,
      'startDate': startDate,
      'endDate': endDate,
      'start_id': startId,
      'end_id': endId,
    };
  }
}
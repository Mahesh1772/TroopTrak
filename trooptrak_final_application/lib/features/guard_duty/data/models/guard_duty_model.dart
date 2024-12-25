import 'package:trooptrak_final_application/features/guard_duty/domain/entities/guard_duty.dart';

class GuardDutyModel extends GuardDuty {
  GuardDutyModel({
    required super.id,
    required super.dutyDate,
    required super.startTime,
    required super.endTime,
    required super.dutyType,
    required super.points,
    required super.participants,
  });

  factory GuardDutyModel.fromJson(Map<String, dynamic> json, String id) {
    return GuardDutyModel(
      id: id,
      dutyDate: json['dutyDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      dutyType: json['dayType'],
      points: json['points'] is int ? json['points'] : json['points'].toInt(),
      participants: Map<String, String>.from(json['participants']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dutyDate': dutyDate,
      'startTime': startTime,
      'endTime': endTime,
      'dayType': dutyType,
      'points': points,
      'participants': participants,
    };
  }
} 
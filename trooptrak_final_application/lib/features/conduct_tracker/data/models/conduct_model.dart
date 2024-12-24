import 'package:trooptrak_final_application/features/conduct_tracker/domain/entities/conduct.dart';

class ConductModel extends Conduct {
  ConductModel({
    required super.id,
    required super.conductName,
    required super.conductType,
    required super.startDate,
    required super.startTime,
    required super.endTime,
    required super.participants,
    required super.nonParticipants,  // Add this
    required super.soldierReason,
  });

  factory ConductModel.fromJson(Map<String, dynamic> json, String id) {
    return ConductModel(
      id: id,
      conductName: json['conductName'] as String,
      conductType: json['conductType'] as String,
      startDate: json['startDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      participants: List<String>.from(json['participants'] as List),
      nonParticipants: List<String>.from(json['nonParticipants'] as List? ?? []),  // Add this
      soldierReason: Map<String, String>.from(json['soldierReason'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conductName': conductName,
      'conductType': conductType,
      'startDate': startDate,
      'startTime': startTime,
      'endTime': endTime,
      'participants': participants,
      'nonParticipants': nonParticipants,  // Add this
      'soldierReason': soldierReason,
    };
  }
}
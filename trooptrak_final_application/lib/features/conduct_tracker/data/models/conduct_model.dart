import 'package:trooptrak_final_application/features/conduct_tracker/domain/entities/conduct.dart';

class ConductModel extends Conduct {
  ConductModel({
    required String id,
    required String conductName,
    required String conductType,
    required String startDate,
    required String startTime,
    required String endTime,
    required List<String> participants,
    required List<String> nonParticipants,  // Add this
    required Map<String, String> soldierReason,
  }) : super(
          id: id,
          conductName: conductName,
          conductType: conductType,
          startDate: startDate,
          startTime: startTime,
          endTime: endTime,
          participants: participants,
          nonParticipants: nonParticipants,  // Add this
          soldierReason: soldierReason,
        );

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
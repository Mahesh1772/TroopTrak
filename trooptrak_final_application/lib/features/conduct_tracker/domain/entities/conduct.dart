import 'package:flutter/material.dart';

class Conduct {
  final String id;
  final String conductName;
  final String conductType;
  final String startDate;
  final String startTime;
  final String endTime;
  final List<String> participants;
  final List<String> nonParticipants;
  final Map<String, String> soldierReason;

  const Conduct({
    required this.id,
    required this.conductName,
    required this.conductType,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.participants,
    required this.nonParticipants,
    required this.soldierReason,
  });

  static IconData getIconForConductType(String conductType) {
    switch (conductType.toLowerCase()) {
      case 'run':
        return Icons.directions_run_rounded;
      case 's&p':
        return Icons.fitness_center_rounded;
      case 'imt':
        return Icons.gps_fixed_rounded;
      case 'atp':
        return Icons.adjust_rounded;
      case 'ippt':
        return Icons.military_tech_rounded;
      case 'soc':
        return Icons.park_rounded;
      case 'metabolic circuit':
        return Icons.flash_on_rounded;
      case 'combat circuit':
        return Icons.shield_rounded;
      case 'route march':
        return Icons.hiking_rounded;
      case 'outfield':
        return Icons.forest_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conductName': conductName,
      'conductType': conductType,
      'startDate': startDate,
      'startTime': startTime,
      'endTime': endTime,
      'participants': participants,
      'nonParticipants': nonParticipants,
      'soldierReason': soldierReason,
    };
  }

  factory Conduct.fromMap(Map<String, dynamic> map) {
    return Conduct(
      id: map['id'] ?? '',
      conductName: map['conductName'] ?? '',
      conductType: map['conductType'] ?? '',
      startDate: map['startDate'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      nonParticipants: List<String>.from(map['nonParticipants'] ?? []),
      soldierReason: Map<String, String>.from(map['soldierReason'] ?? {}),
    );
  }
}
class Conduct {
  final String id;
  final String conductName;
  final String conductType;
  final String startDate;
  final String startTime;
  final String endTime;
  final List<String> participants;
  final List<String> nonParticipants;  // Add this
  final Map<String, String> soldierReason;

  Conduct({
    required this.id,
    required this.conductName,
    required this.conductType,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.participants,
    required this.nonParticipants,  // Add this
    required this.soldierReason,
  });
}
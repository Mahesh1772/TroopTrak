class GuardDuty {
  final String id;
  final String dutyDate;
  final String startTime;
  final String endTime;
  final String dutyType;
  final int points;
  final Map<String, String> participants; // Map of name to rank

  const GuardDuty({
    required this.id,
    required this.dutyDate,
    required this.startTime,
    required this.endTime,
    required this.dutyType,
    required this.points,
    required this.participants,
  });
} 
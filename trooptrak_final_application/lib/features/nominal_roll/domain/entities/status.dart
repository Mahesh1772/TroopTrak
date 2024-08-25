class Status {
  final String statusName;
  final String statusType;
  final String startDate;
  final String endDate;
  final String startId;
  final String endId;

  Status({
    required this.statusName,
    required this.statusType,
    required this.startDate,
    required this.endDate,
    required this.startId,
    required this.endId,
  });

  @override
  String toString() {
    return 'Status(statusName: $statusName, statusType: $statusType, startDate: $startDate, endDate: $endDate, startId: $startId, endId: $endId)';
  }
}

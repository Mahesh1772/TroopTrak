class Status {
  final String id;
  final String statusType;
  final String statusName;
  final String startId;
  final String endId;

  Status({
    required this.id,
    required this.statusType,
    required this.statusName,
    required this.startId,
    required this.endId,
  });

  String get startDate => _formatDate(startId);
  String get endDate => _formatDate(endId);

  String _formatDate(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
}
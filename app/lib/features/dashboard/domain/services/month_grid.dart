import 'package:equatable/equatable.dart';

class MonthCell extends Equatable {
  const MonthCell(this.date, {required this.inMonth});

  final DateTime date;
  final bool inMonth;

  @override
  List<Object?> get props => [date, inMonth];
}

/// Monday-first weeks covering [month]; days of the neighbouring months fill
/// the first and last week.
List<List<MonthCell>> monthWeeks(DateTime month) {
  final length = DateTime(month.year, month.month + 1, 0).day;
  final lead = DateTime(month.year, month.month).weekday - DateTime.monday;
  final trail =
      DateTime.sunday - DateTime(month.year, month.month, length).weekday;
  final cells = [
    for (var i = -lead; i < length + trail; i++)
      MonthCell(
        DateTime(month.year, month.month, 1 + i),
        inMonth: i >= 0 && i < length,
      ),
  ];
  return [
    for (var i = 0; i < cells.length; i += DateTime.daysPerWeek)
      cells.sublist(i, i + DateTime.daysPerWeek),
  ];
}

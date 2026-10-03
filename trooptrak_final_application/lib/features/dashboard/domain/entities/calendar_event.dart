import 'package:equatable/equatable.dart';

enum CalendarEventKind { conduct, guardDuty }

class CalendarEvent extends Equatable {
  const CalendarEvent({
    required this.title,
    required this.start,
    required this.end,
    required this.kind,
  });

  final String title;
  final DateTime start;
  final DateTime end;
  final CalendarEventKind kind;

  DateTime get day => DateTime(start.year, start.month, start.day);

  /// Source calendar rule: an end not after the start runs into the next day
  /// (overnight and 24-hour duties).
  static DateTime endFor(DateTime start, DateTime end) =>
      end.isAfter(start) ? end : end.add(const Duration(days: 1));

  @override
  List<Object?> get props => [title, start, end, kind];
}

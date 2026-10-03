import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';

Status buildStatus({
  String id = 's1',
  String soldierId = 'Tan Ah Kow',
  String type = 'Excuse',
  String name = 'Ex RMJ',
  DateTime? start,
  DateTime? end,
  String? startAttendanceId,
  String? endAttendanceId,
}) =>
    Status(
      id: id,
      soldierId: soldierId,
      type: type,
      name: name,
      start: start ?? DateTime(2023, 7, 1),
      end: end ?? DateTime(2023, 7, 7),
      startAttendanceId: startAttendanceId,
      endAttendanceId: endAttendanceId,
    );

Soldier buildSoldier({
  String name = 'Tan Ah Kow',
  String? id,
  String rank = 'CPL',
  String company = 'Alpha',
  String platoon = '1',
  String section = '2',
  String appointment = 'Section IC',
  String rationType = 'NM',
  String bloodGroup = 'O+',
  DateTime? dob,
  DateTime? enlistment,
  DateTime? ord,
  bool isInCamp = true,
  double points = 0,
}) =>
    Soldier(
      id: id ?? name,
      name: name,
      rank: rank,
      company: company,
      platoon: platoon,
      section: section,
      appointment: appointment,
      rationType: rationType,
      bloodGroup: bloodGroup,
      dob: dob ?? DateTime(2000, 7, 5),
      enlistment: enlistment ?? DateTime(2023, 1, 1),
      ord: ord ?? DateTime(2025, 1, 1),
      isInCamp: isInCamp,
      points: points,
    );

Map<String, dynamic> soldierDoc({
  String name = 'Tan Ah Kow',
  String rank = 'CPL',
  String company = 'Alpha',
  String platoon = '1',
  String section = '2',
  String appointment = 'Section IC',
  String rationType = 'NM',
  String bloodGroup = 'O+',
  String dob = '5 Jul 2000',
  String enlistment = '1 Jan 2023',
  String ord = '1 Jan 2025',
  String currentAttendance = 'Inside Camp',
  num points = 0,
}) =>
    {
      'name': name,
      'rank': rank,
      'company': company,
      'platoon': platoon,
      'section': section,
      'appointment': appointment,
      'rationType': rationType,
      'bloodgroup': bloodGroup,
      'dob': dob,
      'enlistment': enlistment,
      'ord': ord,
      'currentAttendance': currentAttendance,
      'points': points,
    };

Map<String, dynamic> statusDoc({
  String type = 'Excuse',
  String name = 'Ex RMJ',
  String startDate = '1 Jul 2023',
  String endDate = '7 Jul 2023',
}) =>
    {
      'statusType': type,
      'statusName': name,
      'startDate': startDate,
      'endDate': endDate,
    };

Map<String, dynamic> attendanceDoc({
  bool isInsideCamp = true,
  String dateTime = 'Wed 5 Jul 2023 08:00:00',
}) =>
    {'isInsideCamp': isInsideCamp, 'date&time': dateTime};

Map<String, dynamic> conductDoc({
  String name = 'Morning Run',
  String type = 'Run',
  String startDate = '5 Jul 2023',
  String startTime = '7:00 AM',
  String endTime = '8:00 AM',
  List<String> participants = const ['Tan Ah Kow'],
  Map<String, String> soldierReason = const {},
}) =>
    {
      'conductName': name,
      'conductType': type,
      'startDate': startDate,
      'startTime': startTime,
      'endTime': endTime,
      'participants': participants,
      'soldierReason': soldierReason,
    };

Map<String, dynamic> dutyDoc({
  String dutyDate = '7 Jul 2023',
  String startTime = '8:00 AM',
  String endTime = '8:00 AM',
  String dayType = 'Weekday (Friday) Duty 😖',
  num points = 1.5,
  Map<String, String> participants = const {'Tan Ah Kow': 'CPL'},
}) =>
    {
      'dutyDate': dutyDate,
      'startTime': startTime,
      'endTime': endTime,
      'dayType': dayType,
      'points': points,
      'participants': participants,
    };

Map<String, dynamic> menDoc({
  String name = 'Lim Bah',
  String rank = 'PTE',
  String? qrId,
}) =>
    {
      ...soldierDoc(name: name, rank: rank)..remove('currentAttendance'),
      'points': 0,
      'QRid': qrId,
    };

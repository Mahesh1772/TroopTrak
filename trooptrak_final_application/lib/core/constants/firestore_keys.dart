abstract final class Collections {
  static const users = 'Users';
  static const statuses = 'Statuses';
  static const attendance = 'Attendance';
  static const conducts = 'Conducts';
  static const duties = 'Duties';
  static const men = 'Men';
}

abstract final class UserFields {
  static const name = 'name';
  static const rank = 'rank';
  static const company = 'company';
  static const platoon = 'platoon';
  static const section = 'section';
  static const appointment = 'appointment';
  static const rationType = 'rationType';
  static const bloodGroup = 'bloodgroup';
  static const dob = 'dob';
  static const enlistment = 'enlistment';
  static const ord = 'ord';
  static const currentAttendance = 'currentAttendance';
  static const points = 'points';
}

abstract final class AttendanceValues {
  static const insideCamp = 'Inside Camp';
  static const outside = 'Outside';
}

abstract final class StatusFields {
  static const statusType = 'statusType';
  static const statusName = 'statusName';
  static const startDate = 'startDate';
  static const endDate = 'endDate';
  static const startAttendanceId = 'start_id';
  static const endAttendanceId = 'end_id';
}

abstract final class AttendanceFields {
  static const isInsideCamp = 'isInsideCamp';
  static const dateTime = 'date&time';
}

abstract final class ConductFields {
  static const conductName = 'conductName';
  static const conductType = 'conductType';
  static const startDate = 'startDate';
  static const startTime = 'startTime';
  static const endTime = 'endTime';
  static const participants = 'participants';
  static const soldierReason = 'soldierReason';
}

abstract final class DutyFields {
  static const dutyDate = 'dutyDate';
  static const startTime = 'startTime';
  static const endTime = 'endTime';
  static const dayType = 'dayType';
  static const points = 'points';
  static const participants = 'participants';
}

abstract final class MenFields {
  static const qrId = 'QRid';
}

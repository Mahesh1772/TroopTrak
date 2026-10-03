import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/data/firestore_helpers.dart';
import '../../../../core/utils/date_formats.dart';
import '../../domain/entities/soldier.dart';

abstract final class SoldierModel {
  static Soldier fromMap(String id, Map<String, dynamic> map) => Soldier(
        id: id,
        name: readString(map[UserFields.name]).isEmpty
            ? id
            : readString(map[UserFields.name]),
        rank: readString(map[UserFields.rank]),
        company: readString(map[UserFields.company]),
        platoon: readString(map[UserFields.platoon]),
        section: readString(map[UserFields.section]),
        appointment: readString(map[UserFields.appointment]),
        rationType: readString(map[UserFields.rationType]),
        bloodGroup: readString(map[UserFields.bloodGroup]),
        dob: parseDay(map[UserFields.dob]?.toString()),
        enlistment: parseDay(map[UserFields.enlistment]?.toString()),
        ord: parseDay(map[UserFields.ord]?.toString()),
        isInCamp: map[UserFields.currentAttendance] != AttendanceValues.outside,
        points: readDouble(map[UserFields.points]),
      );

  static Map<String, dynamic> toProfileMap(Soldier soldier) => {
        UserFields.name: soldier.name,
        UserFields.rank: soldier.rank,
        UserFields.company: soldier.company,
        UserFields.platoon: soldier.platoon,
        UserFields.section: soldier.section,
        UserFields.appointment: soldier.appointment,
        UserFields.rationType: soldier.rationType,
        UserFields.bloodGroup: soldier.bloodGroup,
        UserFields.dob: _day(soldier.dob),
        UserFields.enlistment: _day(soldier.enlistment),
        UserFields.ord: _day(soldier.ord),
      };

  static Map<String, dynamic> toCreateMap(Soldier soldier) => {
        ...toProfileMap(soldier),
        UserFields.currentAttendance: attendanceValue(soldier.isInCamp),
        UserFields.points: soldier.points,
      };

  static String attendanceValue(bool isInCamp) =>
      isInCamp ? AttendanceValues.insideCamp : AttendanceValues.outside;

  static String _day(DateTime? date) => date == null ? '' : formatDay(date);
}

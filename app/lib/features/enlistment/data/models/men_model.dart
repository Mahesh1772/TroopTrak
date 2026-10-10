import '../../../../core/constants/firestore_keys.dart';
import '../../../../core/data/firestore_helpers.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/entities/soldier_registration.dart';

abstract final class MenModel {
  static SoldierRegistration fromMap(String uid, Map<String, dynamic> map) {
    final name = readString(map[UserFields.name]);
    return SoldierRegistration(
      uid: uid,
      profile: Soldier(
        id: name.trim(),
        name: name,
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
        points: readDouble(map[UserFields.points]),
      ),
      qrId: map[MenFields.qrId] as String?,
    );
  }

  /// R16 registration document, in the source's field order.
  static Map<String, dynamic> toCreateMap(Soldier profile) => {
        ...toProfileMap(profile),
        UserFields.points: 0,
        MenFields.qrId: null,
      };

  static Map<String, dynamic> toProfileMap(Soldier profile) => {
        UserFields.rank: profile.rank,
        UserFields.name: profile.name,
        UserFields.company: profile.company,
        UserFields.platoon: profile.platoon,
        UserFields.section: profile.section,
        UserFields.appointment: profile.appointment,
        UserFields.rationType: profile.rationType,
        UserFields.bloodGroup: profile.bloodGroup,
        UserFields.dob: _day(profile.dob),
        UserFields.ord: _day(profile.ord),
        UserFields.enlistment: _day(profile.enlistment),
      };

  static String _day(DateTime? date) => date == null ? '' : formatDay(date);
}

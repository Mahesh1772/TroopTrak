import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/constants/blood_types.dart';
import 'package:trooptrak_final_application/core/constants/conduct_types.dart';
import 'package:trooptrak_final_application/core/constants/firestore_keys.dart';
import 'package:trooptrak_final_application/core/constants/pref_keys.dart';
import 'package:trooptrak_final_application/core/constants/rank_assets.dart';
import 'package:trooptrak_final_application/core/constants/ranks.dart';
import 'package:trooptrak_final_application/core/constants/ration_types.dart';
import 'package:trooptrak_final_application/core/constants/status_names.dart';
import 'package:trooptrak_final_application/core/constants/status_types.dart';

void main() {
  group('rank lists match the source', () {
    test('commander list (add_new_soldier_screen.dart)', () {
      expect(
          Ranks.all,
          'REC PTE LCP CPL CFC SCT 3SG 2SG 1SG SSG MSG 3WO 2WO 1WO MWO SWO CWO OCT 2LT LTA CPT MAJ LTC SLTC COL BG MG LG'
              .split(' '));
    });

    test('soldier self-registration list (get_user_info.dart)', () {
      expect(
          Ranks.soldierRegistration, 'REC PTE LCP CPL CFC SCT OCT'.split(' '));
    });

    test('commander registration list (register_page.dart)', () {
      expect(
          Ranks.commanderRegistration,
          '3SG 2SG 1SG SSG MSG 3WO 2WO 1WO MWO SWO CWO 2LT LTA CPT MAJ LTC SLTC COL BG MG LG'
              .split(' '));
    });

    test('dashboard groups (R4)', () {
      expect(
          Ranks.officers, '2LT LTA CPT MAJ LTC SLTC COL BG MG LG'.split(' '));
      expect(
          Ranks.woses,
          'REC PTE LCP CPL CFC SCT OCT 3SG 2SG 1SG SSG MSG 3WO 2WO 1WO MWO SWO CWO'
              .split(' '));
    });
  });

  group('rank classification', () {
    test('every rank is exactly one of officer or WOSE', () {
      for (final rank in Ranks.all) {
        expect(Ranks.isOfficer(rank) != Ranks.isWose(rank), isTrue,
            reason: rank);
      }
    });

    test('classification ignores case and whitespace', () {
      expect(Ranks.isOfficer(' cpt '), isTrue);
      expect(Ranks.isWose('3sg'), isTrue);
      expect(Ranks.isOfficer('unknown'), isFalse);
      expect(Ranks.isWose(''), isFalse);
    });

    test('groupOf matches the source tile colour groups', () {
      expect(Ranks.groupOf('PTE'), RankGroup.enlisted);
      expect(Ranks.groupOf('SCT'), RankGroup.specialistCadet);
      expect(Ranks.groupOf('MSG'), RankGroup.specialist);
      expect(Ranks.groupOf('CWO'), RankGroup.warrantOfficer);
      expect(Ranks.groupOf('OCT'), RankGroup.officerCadet);
      expect(Ranks.groupOf('LTA'), RankGroup.juniorOfficer);
      expect(Ranks.groupOf('MAJ'), RankGroup.seniorOfficer);
      expect(Ranks.groupOf('XYZ'), RankGroup.unknown);
    });
  });

  group('rank assets (R4)', () {
    test('insignia path is lowercase rank png and exists for every rank', () {
      for (final rank in Ranks.all) {
        final path = RankAssets.insignia(rank);
        expect(path, 'lib/assets/army-ranks/${rank.toLowerCase()}.png');
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    });

    test('person icon is men.png for REC/PTE/LCP/CPL/CFC, else soldier.png',
        () {
      for (final rank in Ranks.all) {
        final expected = Ranks.enlisted.contains(rank)
            ? 'lib/assets/army-ranks/men.png'
            : 'lib/assets/army-ranks/soldier.png';
        expect(RankAssets.personIcon(rank), expected, reason: rank);
      }
      expect(File(RankAssets.menIcon).existsSync(), isTrue);
      expect(File(RankAssets.soldierIcon).existsSync(), isTrue);
    });

    test('insignia tint applies to enlisted, specialists and warrant officers',
        () {
      final tinted = Ranks.all.where(RankAssets.tintInsignia).toList();
      expect(
          tinted,
          'REC PTE LCP CPL CFC 3SG 2SG 1SG SSG MSG 3WO 2WO 1WO MWO SWO CWO'
              .split(' '));
    });
  });

  test('ration, blood, conduct and status lists match the source', () {
    expect(RationTypes.all,
        ['NM', 'M', 'VI', 'VC', 'SD NM', 'SD M', 'SD VI', 'SD VC']);
    expect(BloodTypes.all,
        ['O-', 'O+', 'B-', 'B+', 'A-', 'A+', 'AB-', 'AB+', 'Unknown']);
    expect(ConductTypes.all, [
      'Run',
      'Route March',
      'IPPT',
      'Outfield',
      'Strength & Power',
      'Metabolic Circuit',
      'Combat Circuit',
      'Live Firing',
      'SOC/VOC',
    ]);
    expect(StatusTypes.all, ['Excuse', 'Leave', 'Medical Appointment']);
  });

  test('status name suggestions match add_new_status_screen.dart', () {
    expect(StatusNames.suggestions, hasLength(22));
    expect(StatusNames.suggestions.first, 'LD');
    expect(StatusNames.suggestions[2], 'Ex RMJ ');
    expect(StatusNames.suggestions.last, 'Ex grass');
    expect(StatusNames.suggestions,
        containsAll(['Ex FLEGs', 'Ex Uniform', 'Ex Boots']));
  });

  test('Firestore and preference keys match Appendix B', () {
    expect(
      [
        Collections.users,
        Collections.statuses,
        Collections.attendance,
        Collections.conducts,
        Collections.duties,
        Collections.men
      ],
      ['Users', 'Statuses', 'Attendance', 'Conducts', 'Duties', 'Men'],
    );
    expect(UserFields.bloodGroup, 'bloodgroup');
    expect(UserFields.currentAttendance, 'currentAttendance');
    expect(AttendanceFields.dateTime, 'date&time');
    expect(AttendanceValues.insideCamp, 'Inside Camp');
    expect(AttendanceValues.outside, 'Outside');
    expect(ConductFields.soldierReason, 'soldierReason');
    expect(DutyFields.dayType, 'dayType');
    expect(MenFields.qrId, 'QRid');
    expect(PrefKeys.onBoard, 'onBoard');
    expect(PrefKeys.isSignedIn, 'is_signedin');
  });
}

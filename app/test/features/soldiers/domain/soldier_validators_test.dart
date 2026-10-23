import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/validators/profile_date_limits.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/validators/soldier_validators.dart';

void main() {
  group('SoldierValidators', () {
    test('name: empty, all-numeric, shorter than 5', () {
      expect(SoldierValidators.name(''), 'Must have a name right');
      expect(SoldierValidators.name(null), 'Must have a name right');
      expect(SoldierValidators.name('12345'), 'Name got number meh');
      expect(SoldierValidators.name('Tan'), 'Brother, enter full name leh');
      expect(SoldierValidators.name('Tan 2nd'), isNull);
    });

    test('text fields reject blanks with their own message', () {
      for (final (rule, message) in [
        (SoldierValidators.appointment, 'Appointment Missing'),
        (SoldierValidators.company, 'Company Name Missing'),
        (SoldierValidators.platoon, 'Platoon Information Missing'),
        (SoldierValidators.section, 'Section Information Missing'),
      ]) {
        expect(rule(null), message);
        expect(rule('   '), message);
        expect(rule(' A '), isNull);
      }
    });

    test('choices reject null with their own message', () {
      expect(SoldierValidators.rationType(null), 'Walao what food you eat?');
      expect(SoldierValidators.rationType('NM'), isNull);
      expect(SoldierValidators.rank(null), 'Walao provide rank liao');
      expect(SoldierValidators.rank('PTE'), isNull);
      expect(
          SoldierValidators.bloodGroup(null), 'Why your blood field empty ah?');
      expect(SoldierValidators.bloodGroup('O+'), isNull);
    });

    test('dates reject null with their own message', () {
      final day = DateTime(2023, 7, 5);
      expect(SoldierValidators.dateOfBirth(null), 'Select your date of birth');
      expect(SoldierValidators.dateOfBirth(day), isNull);
      expect(SoldierValidators.enlistmentDate(null),
          'Select your enlistment date');
      expect(SoldierValidators.enlistmentDate(day), isNull);
      expect(SoldierValidators.ordDate(null), 'Select your ORD date');
      expect(SoldierValidators.ordDate(day), isNull);
    });
  });

  test('ProfileDateLimits: birth stops today, other dates run to 2100', () {
    final today = DateTime(2023, 7, 5);
    expect(ProfileDateLimits.earliest, DateTime(1960));
    expect(ProfileDateLimits.latest, DateTime(2100));
    expect(ProfileDateLimits.latestBirth(today), today);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/constants/status_names.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/book_out_note.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/status_suggestions.dart';
import 'package:trooptrak_final_application/features/statuses/domain/validators/status_validators.dart';

import '../../../helpers/builders.dart';

void main() {
  group('StatusValidators', () {
    test('type needs a choice', () {
      expect(StatusValidators.type(null), 'Bruh select Dei!');
      expect(StatusValidators.type('Leave'), isNull);
    });

    test('name needs something other than spaces', () {
      const message = 'Oi can enter the status type please?';
      expect(StatusValidators.name(null), message);
      expect(StatusValidators.name('  '), message);
      expect(StatusValidators.name(' OL '), isNull);
    });

    test('K18: the end day may equal the start day but not precede it', () {
      final start = DateTime(2023, 7, 5, 9);
      expect(StatusValidators.period(start, DateTime(2023, 7, 4, 23)),
          endBeforeStart);
      expect(StatusValidators.period(start, DateTime(2023, 7, 5)), isNull);
      expect(StatusValidators.period(start, DateTime(2023, 7, 6)), isNull);
    });
  });

  group('suggestStatusNames', () {
    test('only an Excuse has suggestions', () {
      expect(suggestStatusNames('Leave', ''), isEmpty);
      expect(suggestStatusNames('Medical Appointment', 'ex'), isEmpty);
      expect(suggestStatusNames(null, ''), isEmpty);
    });

    test('nothing typed shows the common names', () {
      expect(suggestStatusNames('Excuse', ''), StatusNames.common);
      expect(suggestStatusNames('Excuse', '  '), StatusNames.common);
      expect(StatusNames.common, hasLength(9));
    });

    test('typing keeps the names containing it, ignoring case, trimmed', () {
      expect(suggestStatusNames('Excuse', 'LIMB'),
          ['Ex Upper Limb', 'Ex Lower Limb']);
      expect(suggestStatusNames('Excuse', ' rmj '), ['Ex RMJ']);
      expect(suggestStatusNames('Excuse', 'zzz'), isEmpty);
    });

    test('a name typed in full keeps the common names beside it', () {
      final shown = suggestStatusNames('Excuse', 'Ex RMJ');
      expect(shown, StatusNames.common);
      final rare = suggestStatusNames('Excuse', 'ex grass');
      expect(rare, [...StatusNames.common, 'Ex grass']);
    });
  });

  group('bookOutNote', () {
    final soldier = buildSoldier(name: 'Sean Koh');
    final period = (start: DateTime(2023, 7, 3), end: DateTime(2023, 7, 5));

    test('is null for an Excuse', () {
      expect(
          bookOutNote(
              buildStatus(type: 'Excuse', start: period.start, end: period.end),
              soldier),
          isNull);
    });

    test('Leave and MA say when the soldier is booked out and back in', () {
      expect(
          bookOutNote(
              buildStatus(type: 'Leave', start: period.start, end: period.end),
              soldier),
          'Leave books Sean out at 00:30 on the start day and back in at '
          '22:00 on the end day.');
      expect(
          bookOutNote(
              buildStatus(
                  type: 'Medical Appointment',
                  start: period.start,
                  end: period.end),
              soldier),
          startsWith('Medical Appointment books Sean out'));
    });

    test('is null while no type is chosen', () {
      expect(bookOutNote(buildStatus(type: ''), soldier), isNull);
    });
  });
}

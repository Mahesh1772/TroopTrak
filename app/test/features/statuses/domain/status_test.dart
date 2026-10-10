import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';

import '../../../helpers/builders.dart';

void main() {
  final status =
      buildStatus(start: DateTime(2023, 7, 3), end: DateTime(2023, 7, 5));

  group('isActiveOn (R2)', () {
    test('active through the end day inclusive, any time of day', () {
      expect(status.isActiveOn(DateTime(2023, 7, 5, 23, 59)), isTrue);
      expect(status.isActiveOn(DateTime(2023, 7, 5)), isTrue);
    });

    test('expired from the day after the end', () {
      expect(status.isActiveOn(DateTime(2023, 7, 6)), isFalse);
      expect(status.isActiveOn(DateTime(2024, 1, 1)), isFalse);
    });

    test('start day is not checked: future statuses count as active', () {
      expect(status.isActiveOn(DateTime(2023, 7, 1)), isTrue);
    });
  });

  group('isCurrentOnDashboard (R3)', () {
    test('requires start on or before today', () {
      expect(status.isCurrentOnDashboard(DateTime(2023, 7, 2)), isFalse);
      expect(status.isCurrentOnDashboard(DateTime(2023, 7, 3)), isTrue);
      expect(status.isCurrentOnDashboard(DateTime(2023, 7, 5, 22)), isTrue);
      expect(status.isCurrentOnDashboard(DateTime(2023, 7, 6)), isFalse);
    });
  });

  group('linked attendance (R21)', () {
    test('Leave and MA book out at 00:30 on start and in at 22:00 on end', () {
      for (final type in ['Leave', 'Medical Appointment']) {
        final s = buildStatus(
            type: type, start: DateTime(2023, 7, 3), end: DateTime(2023, 7, 5));
        expect(s.linkedAttendance, [
          (at: DateTime(2023, 7, 3, 0, 30), isInsideCamp: false),
          (at: DateTime(2023, 7, 5, 22), isInsideCamp: true),
        ]);
      }
    });

    test('Excuse has no linked attendance', () {
      expect(buildStatus(type: 'Excuse').linkedAttendance, isEmpty);
    });
  });

  test('type helpers', () {
    expect(buildStatus(type: 'Excuse').isExcuse, isTrue);
    expect(buildStatus(type: 'Leave').isLeave, isTrue);
    expect(
        buildStatus(type: 'Medical Appointment').isMedicalAppointment, isTrue);
  });

  test('partitionStatuses splits active and past', () {
    final active = buildStatus(id: 'a', end: DateTime(2023, 7, 5));
    final past = buildStatus(id: 'p', end: DateTime(2023, 7, 4));
    final split = partitionStatuses([active, past], DateTime(2023, 7, 5, 9));
    expect(split.active, [active]);
    expect(split.past, [past]);
  });

  test('equality and copyWith', () {
    expect(buildStatus(), buildStatus());
    expect(buildStatus().copyWith(name: 'LD'), buildStatus(name: 'LD'));
    expect(buildStatus(), isNot(buildStatus(endAttendanceId: 'x')));
  });
}

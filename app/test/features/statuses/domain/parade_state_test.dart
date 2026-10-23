import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/constants/status_types.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_state.dart';

import '../../../helpers/builders.dart';

void main() {
  ParadeState stateOf({String? type, bool inCamp = true}) => paradeStateOf(
        buildSoldier(isInCamp: inCamp),
        type == null ? null : buildStatus(type: type),
      );

  test('Leave is leave, in camp or out', () {
    expect(stateOf(type: StatusTypes.leave), ParadeState.leave);
    expect(stateOf(type: StatusTypes.leave, inCamp: false), ParadeState.leave);
  });

  test('Medical Appointment is medical, in camp or out', () {
    expect(
      stateOf(type: StatusTypes.medicalAppointment),
      ParadeState.medical,
    );
    expect(
      stateOf(type: StatusTypes.medicalAppointment, inCamp: false),
      ParadeState.medical,
    );
  });

  test('Excuse only shows while in camp', () {
    expect(stateOf(type: StatusTypes.excuse), ParadeState.excuse);
    expect(stateOf(type: StatusTypes.excuse, inCamp: false), ParadeState.out);
  });

  test('without a status the booked-in flag decides', () {
    expect(stateOf(), ParadeState.inCamp);
    expect(stateOf(inCamp: false), ParadeState.out);
  });

  test('declared in tick-strip order', () {
    expect(ParadeState.values, [
      ParadeState.inCamp,
      ParadeState.excuse,
      ParadeState.medical,
      ParadeState.leave,
      ParadeState.out,
    ]);
  });

  test('each state has the label the parade report shows', () {
    expect(ParadeState.values.map((s) => s.label), [
      'In camp',
      'Excuse · in camp',
      'Medical Appointment',
      'Leave',
      'Booked out',
    ]);
  });
}

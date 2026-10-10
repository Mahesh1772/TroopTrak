import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';

import 'support/driver.dart';
import 'support/emulator.dart';

const commander = 'Alex Tan';
const soldier = 'Ben Lim';
const excuse = 'Ex RMJ';

/// R7 points by weekday.
const dutyPoints = {
  DateTime.monday: 1.0,
  DateTime.tuesday: 1.0,
  DateTime.wednesday: 1.0,
  DateTime.thursday: 1.0,
  DateTime.friday: 1.5,
  DateTime.saturday: 2.5,
  DateTime.sunday: 2.0,
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(Emulators.start);
  setUp(Emulators.reset);

  testWidgets(
      'commander registers, adds a soldier, status, conduct and duty, '
      'and the dashboard counts them', (tester) async {
    await launchApp(tester);

    await tester.tapKey('role-commander');
    await tester.tapKey('role-confirm');
    await tester.tapKey('registerPageButton');
    await tester.fillProfile(name: 'alex tan', rank: '2LT');
    await tester.type('register-email', 'alex@unit.sg');
    await tester.type('register-password', 'Trooper1!');
    await tester.type('register-confirm', 'Trooper1!');
    tester.hideKeyboard();
    await tester.tapKey('registerButton');

    await tester.waitFor(find.byKey(const Key('signInButton')));
    await tester.type('email', 'alex@unit.sg');
    await tester.type('password', 'Trooper1!');
    tester.hideKeyboard();
    await tester.tapKey('signInButton');
    await tester.waitFor(find.text('Welcome,\n$commander! 👋'));
    expect(await Emulators.read('Users/$commander'),
        containsPair('currentAttendance', 'Inside Camp'));
    expect((await Emulators.readAll('Users/$commander/Attendance')).single,
        containsPair('isInsideCamp', true));

    await tester.tapKey('nominalRoll');
    await tester.waitFor(find.byKey(const Key('scanQr')));
    // The camera scan cannot run on an emulator; open the form it leads to.
    unawaited(Navigator.of(tester.element(find.byKey(const Key('scanQr'))))
        .pushNamed(AppRoutes.addSoldier));
    await tester.fillProfile(name: soldier, rank: 'PTE');
    await tester.submit('saveSoldier');

    await tester.tapKey('soldierTile-$soldier');
    await tester.tapOn(find.text('STATUSES'));
    await tester.tapKey('addStatus');
    await tester.choose('statusType', 'Excuse');
    await tester.type('statusName', excuse);
    tester.hideKeyboard();
    await tester.submit('saveStatus');
    await tester.waitFor(find.descendant(
        of: find.byKey(const Key('activeStatuses')),
        matching: find.text(excuse)));
    await tester.fling(
        find.text('Active Statuses'), const Offset(0, 1000), 3000);
    await tester.tapKey('profileBack');

    await tester.tapKey('conductTracker');
    await tester.tapKey('addConduct');
    await tester.choose('conductType', 'Run');
    await tester.type('conductName', 'Morning Run');
    tester.hideKeyboard();
    await tester.acceptPicker('conductDate');
    await tester.acceptPicker('startTime');
    await tester.acceptPicker('endTime');
    final excludedRow = find.byKey(const Key('participant-$soldier'));
    await tester
        .waitFor(find.descendant(of: excludedRow, matching: find.text(excuse)));
    expect(
        find.descendant(
            of: find.byKey(const Key('toggle-$soldier')),
            matching: find.text('ADD')),
        findsOneWidget);
    await tester.submit('saveConduct');
    await tester.waitFor(find.text('Morning Run'));

    final conducts = await Emulators.readAll('Conducts');
    expect(conducts, hasLength(1));
    expect(conducts.single['participants'], [commander]);
    expect(conducts.single['soldierReason'], {soldier: excuse});

    await tester.tapKey('guardDuty');
    await tester.tapKey('addDuty');
    await tester.tapKey('slot-0');
    await tester.tapKey('pick-$soldier');
    await tester.tapKey('pickerDone');
    await tester.acceptPicker('dutyDate');
    await tester.acceptPicker('dutyStart');
    await tester.acceptPicker('dutyEnd');
    await tester.submit('saveDuty');

    final points = dutyPoints[DateTime.now().weekday]!;
    await tester.eventually(() async {
      expect((await Emulators.read('Users/$soldier'))!['points'], points);
    });
    expect((await Emulators.read('Users/$commander'))!['points'], 0);
    final duties = await Emulators.readAll('Duties');
    expect(duties.single['points'], points);
    expect(duties.single['participants'], {soldier: 'PTE'});

    await tester.tapKey('home');
    Finder count(String tile, String value) => find.descendant(
        of: find.byKey(Key('tile-$tile')), matching: find.text(value));
    await tester.waitFor(count('On Status', '1 / 2'));
    expect(count('Total Officers', '1 / 1'), findsOneWidget);
    expect(count('Total WOSEs', '1 / 1'), findsOneWidget);
    expect(count('On MA', '0 / 2'), findsOneWidget);
  });
}

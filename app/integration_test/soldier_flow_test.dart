import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/driver.dart';
import 'support/emulator.dart';

const phone = '91234567';
const name = 'Chen Wei';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(Emulators.start);
  setUp(Emulators.reset);

  testWidgets('soldier signs in by OTP, captures a profile and shows a QR',
      (tester) async {
    await launchApp(tester);

    await tester.tapKey('role-soldier');
    await tester.tapKey('role-confirm');
    await tester.tapKey('getStarted');
    await tester.type('phone', phone);
    tester.hideKeyboard();
    await tester.tapKey('sendCode');
    await tester.waitFor(find.text('User Verification'));

    final code = await Emulators.verificationCode('+65$phone');
    await tester.enterText(
        find.descendant(
            of: find.byKey(const Key('otp')),
            matching: find.byType(EditableText)),
        code);
    await tester.waitFor(find.byKey(const Key('captureButton')),
        timeout: const Duration(seconds: 60));

    await tester.fillProfile(name: name, rank: 'PTE', pickDates: true);
    await tester.tapKey('captureButton');
    await tester.waitFor(find.byKey(const Key('showQr')));

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final men = await Emulators.read('Men/$uid');
    expect(men, containsPair('name', name));
    expect(men, containsPair('rank', 'PTE'));
    expect(men, containsPair('points', 0));
    expect(men!['dob'], isA<String>());

    await tester.tapKey('showQr');
    await tester.waitFor(find.byKey(const Key('qrImage')));
    await tester.eventually(() async {
      expect((await Emulators.read('Men/$uid'))!['QRid'], isNotEmpty);
    });

    await tester.tapKey('closeQr');
    await tester.eventually(() async {
      expect((await Emulators.read('Men/$uid'))!['QRid'], isNull);
    });
  });
}

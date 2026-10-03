import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/services/clock.dart';

import 'fake_clock.dart';
import 'firestore_seed.dart';
import 'pump_app.dart';

void main() {
  test('FixedClock returns, sets and advances a fixed time', () {
    final clock = FixedClock(DateTime(2023, 7, 5));
    expect(clock.now(), DateTime(2023, 7, 5));
    clock.advance(const Duration(days: 1));
    expect(clock.now(), DateTime(2023, 7, 6));
    clock.set(DateTime(2024));
    expect(clock.now(), DateTime(2024));
  });

  test('seedSampleUnit writes Appendix B documents', () async {
    final db = await seedSampleUnit();

    final users = await db.collection('Users').get();
    expect(users.docs.map((d) => d.id), containsAll(['Tan Ah Kow', 'Lee Wei']));
    final tan = users.docs.firstWhere((d) => d.id == 'Tan Ah Kow').data();
    expect(
        tan.keys, containsAll(['bloodgroup', 'currentAttendance', 'points']));

    final statuses = await db
        .collection('Users')
        .doc('Tan Ah Kow')
        .collection('Statuses')
        .get();
    expect(statuses.docs.single.data()['statusName'], 'Ex RMJ');

    final attendance = await db
        .collection('Users')
        .doc('Tan Ah Kow')
        .collection('Attendance')
        .doc('2023-07-05 08:00:00')
        .get();
    expect(attendance.data()?['date&time'], 'Wed 5 Jul 2023 08:00:00');

    expect(
        (await db.collection('Conducts').get())
            .docs
            .single
            .data()['conductType'],
        'Run');
    expect((await db.collection('Duties').get()).docs.single.data()['points'],
        1.5);
    final men =
        await db.collection('Men').where('QRid', isEqualTo: 'qr-123').get();
    expect(men.docs.single.id, 'uid-1');
  });

  testWidgets('pumpApp provides a fixed clock and records named routes',
      (tester) async {
    final recorder = RouteRecorder();
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context)
              .pushNamed('/details', arguments: 'Tan Ah Kow'),
          child: Text('${context.read<Clock>().now().year}'),
        ),
      ),
      observers: [recorder],
    );
    expect(find.text('2023'), findsOneWidget);

    await tester.tap(find.text('2023'));
    await tester.pumpAndSettle();
    expect(recorder.names.last, '/details');
    expect(recorder.lastArguments, 'Tan Ah Kow');
    expect(find.text('route:/details'), findsOneWidget);
  });
}

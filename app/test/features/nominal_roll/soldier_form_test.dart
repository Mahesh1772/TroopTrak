import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/nominal_roll/presentation/pages/soldier_form_page.dart';
import 'package:trooptrak_final_application/features/soldiers/data/datasources/soldier_remote_data_source.dart';
import 'package:trooptrak_final_application/features/soldiers/data/repositories/soldier_repository_impl.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/usecases/soldier_usecases.dart';

import '../../helpers/builders.dart';
import '../../helpers/fake_clock.dart';
import '../../helpers/pump_app.dart';

class _MockAdd extends Mock implements AddSoldier {}

class _MockUpdate extends Mock implements UpdateSoldier {}

void main() {
  late _MockAdd add;
  late _MockUpdate update;
  final clock = FixedClock(DateTime(2023, 7, 5, 9, 30));

  setUpAll(() => registerFallbackValue(buildSoldier()));

  setUp(() {
    add = _MockAdd();
    update = _MockUpdate();
    when(() => add(any())).thenAnswer((_) async => const Right(unit));
    when(() => update(any())).thenAnswer((_) async => const Right(unit));
  });

  Future<void> pumpForm(WidgetTester tester, SoldierFormMode mode,
      {Soldier? initial,
      AddSoldier? addSoldier,
      ThemeMode theme = ThemeMode.dark}) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => SoldierFormPage(mode: mode, initial: initial),
            )),
            child: const Text('open'),
          ),
        ),
      ),
      mode: theme,
      clock: clock,
      providers: [
        Provider<AddSoldier>.value(value: addSoldier ?? add),
        Provider<UpdateSoldier>.value(value: update),
      ],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    final button = find.byKey(const Key('saveSoldier'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('add mode with no prefill shows the source texts and validators',
      (tester) async {
    await pumpForm(tester, SoldierFormMode.add,
        theme: themeModes.currentValue!);
    expect(find.text("Let's get things set up  ✍️"), findsOneWidget);
    expect(find.text('5 Jul 2023'), findsNWidgets(3));
    await save(tester);
    for (final message in [
      'Must have a name right',
      'Walao provide rank liao',
      'Walao what food you eat?',
      'Why your blood field empty ah?',
      'Company Name Missing',
    ]) {
      await tester.ensureVisible(find.text(message));
      expect(find.text(message), findsOneWidget, reason: message);
    }
    expect(find.text('Details missing'), findsOneWidget);
    verifyNever(() => add(any()));
  }, variant: themeModes);

  testWidgets('rank list is the commander list', (tester) async {
    await pumpForm(tester, SoldierFormMode.add);
    final field = find.byKey(const Key('profile-rank'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.tap(field);
    await tester.pumpAndSettle();
    expect(find.text('REC'), findsWidgets);
    expect(find.text('3SG'), findsWidgets);
  });

  testWidgets('a scanned prefill adds the exact soldier and returns home',
      (tester) async {
    final scanned = buildSoldier(name: 'Lim Bah', id: 'Lim Bah', rank: 'PTE');
    await pumpForm(tester, SoldierFormMode.add, initial: scanned);
    expect(find.text('Lim Bah'), findsOneWidget);
    await save(tester);

    final saved = verify(() => add(captureAny())).captured.single as Soldier;
    expect(saved, scanned.copyWith(id: '', isInCamp: true, points: 0));
    expect(find.text('open'), findsOneWidget);
    expect(find.text('Soldier tile created'), findsOneWidget);
  });

  testWidgets('a duplicate name (K13) is reported and the form stays',
      (tester) async {
    when(() => add(any())).thenAnswer((_) async => const Left(
        ValidationFailure('A soldier named Lim Bah already exists.')));
    await pumpForm(tester, SoldierFormMode.add,
        initial: buildSoldier(name: 'Lim Bah'));
    await save(tester);
    expect(
        find.text('A soldier named Lim Bah already exists.'), findsOneWidget);
    expect(find.byType(SoldierFormPage), findsOneWidget);
  });

  testWidgets('edit keeps the doc id, points and in-camp state (K14)',
      (tester) async {
    final existing =
        buildSoldier(name: 'Tan Ah Kow', points: 4.5, isInCamp: false);
    await pumpForm(tester, SoldierFormMode.edit, initial: existing);
    expect(find.text('Change details  ✍️'), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('profile-name')), 'Tan Renamed');
    await save(tester);

    final saved = verify(() => update(captureAny())).captured.single as Soldier;
    expect(saved, existing.copyWith(name: 'Tan Renamed'));
    expect(find.text('Soldier details updated'), findsOneWidget);
    expect(find.byType(SoldierFormPage), findsNothing);
  });

  testWidgets('add writes the Appendix B Users doc through the real use case',
      (tester) async {
    final db = FakeFirebaseFirestore();
    final useCase =
        AddSoldier(SoldierRepositoryImpl(SoldierRemoteDataSource(db)), clock);
    await pumpForm(tester, SoldierFormMode.add,
        initial: buildSoldier(name: ' Lim Bah ', rank: 'PTE'),
        addSoldier: useCase);
    await save(tester);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));

    final doc = (await db.collection('Users').doc('Lim Bah').get()).data();
    expect(doc, {
      'name': 'Lim Bah',
      'rank': 'PTE',
      'company': 'Alpha',
      'platoon': '1',
      'section': '2',
      'appointment': 'Section IC',
      'rationType': 'NM',
      'bloodgroup': 'O+',
      'dob': '5 Jul 2000',
      'enlistment': '1 Jan 2023',
      'ord': '1 Jan 2025',
      'currentAttendance': 'Inside Camp',
      'points': 0.0,
    });
    final attendance = await db
        .collection('Users')
        .doc('Lim Bah')
        .collection('Attendance')
        .get();
    expect(attendance.docs.single.id, '2023-07-05 09:30:00');
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/core/widgets/rank_plate.dart';
import 'package:trooptrak_final_application/features/guard_duty/data/datasources/duty_remote_data_source.dart';
import 'package:trooptrak_final_application/features/guard_duty/data/repositories/duty_repository_impl.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/entities/duty.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/usecases/duty_usecases.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/pages/duty_form_page.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/providers/duty_form_provider.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';
import '../../../helpers/firestore_seed.dart';
import '../../../helpers/pump_app.dart';

class _MockRoster extends Mock implements GetDutyRoster {}

class _MockAdd extends Mock implements AddDuty {}

class _MockUpdate extends Mock implements UpdateDuty {}

void main() {
  final clock = FixedClock(DateTime(2023, 7, 5, 9));
  final tan = buildSoldier(name: 'Tan Ah Kow', rank: 'CPL');
  final lee = buildSoldier(name: 'Lee Wei', rank: '2LT');
  final lim = buildSoldier(name: 'Lim Bah', rank: 'PTE');
  late _MockRoster roster;
  late _MockAdd add;
  late _MockUpdate update;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(buildDuty());
    registerFallbackValue(
        UpdateDutyParams(previous: buildDuty(), updated: buildDuty()));
  });

  setUp(() {
    roster = _MockRoster();
    add = _MockAdd();
    update = _MockUpdate();
    when(() => roster(any())).thenAnswer((_) async => Right(
        DutyRoster(soldiers: [tan, lee, lim], ineligible: const {'Lee Wei'})));
    when(() => add(any())).thenAnswer((_) async => const Right(unit));
    when(() => update(any())).thenAnswer((_) async => const Right(unit));
  });

  DutyFormProvider provider({Duty? initial, AddDuty? addDuty}) =>
      DutyFormProvider(
          roster: roster,
          add: addDuty ?? add,
          update: update,
          initial: initial);

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('DutyFormProvider', () {
    test('pricing follows the picked date (R7)', () {
      final p = provider();
      expect(p.pricing.points, 0);
      p.setDate(DateTime(2023, 7, 8));
      expect(
          p.pricing, (points: 2.5, dayType: 'Weekend (Saturday) Duty 😵‍💫'));
      p.dispose();
    });

    test('the day label drops the emoji (D11)', () {
      final p = provider();
      expect(p.dayLabel, 'Select a duty date!');
      p.setDate(DateTime(2023, 7, 8));
      expect(p.dayLabel, 'Weekend (Saturday) Duty');
      p.setDate(DateTime(2023, 7, 5));
      expect(p.dayLabel, 'Weekday Duty');
      p.dispose();
    });

    test('an end time not after the start runs into the next day (D10)', () {
      final p = provider();
      expect(p.endsNextDay, isFalse);
      p.setStart(const TimeOfDay(hour: 8, minute: 0));
      expect(p.endsNextDay, isFalse);
      p.setEnd(const TimeOfDay(hour: 8, minute: 0));
      expect(p.endsNextDay, isTrue);
      p.setEnd(const TimeOfDay(hour: 8, minute: 1));
      expect(p.endsNextDay, isFalse);
      p.setStart(const TimeOfDay(hour: 20, minute: 0));
      expect(p.endsNextDay, isTrue);
      p.dispose();
    });

    test('an ineligible soldier carries the status that rules them out',
        () async {
      when(() => roster(any())).thenAnswer((_) async => Right(DutyRoster(
          soldiers: [tan, lee],
          ineligible: const {'Lee Wei'},
          reasons: const {'Lee Wei': 'OL'})));
      final p = provider();
      await settle();
      expect(p.reasonFor(lee), 'OL');
      expect(p.reasonFor(tan), isNull);
      p.dispose();
    });

    test('only eligible soldiers join; ten slots at most (R6, R10a)', () async {
      final p = provider();
      await settle();
      expect(p.toggle(tan), isNull);
      expect(p.participants, {'Tan Ah Kow': 'CPL'});
      expect(p.toggle(lee), 'Lee Wei is ineligible for guard duty.');
      expect(p.toggle(tan), isNull);
      expect(p.participants, isEmpty);

      when(() => roster(any())).thenAnswer((_) async => Right(DutyRoster(
          soldiers: [for (var i = 0; i < 11; i++) buildSoldier(name: 'S$i')],
          ineligible: const {})));
      final full = provider();
      await settle();
      for (final s in full.roster.dataOrNull!.soldiers.take(10)) {
        expect(full.toggle(s), isNull);
      }
      expect(full.toggle(full.roster.dataOrNull!.soldiers.last), tooManySlots);
      expect(full.participants.length, 10);
      p.dispose();
      full.dispose();
    });

    test('submit builds the priced duty from date and times', () async {
      final p = provider()
        ..setDate(DateTime(2023, 7, 7))
        ..setStart(const TimeOfDay(hour: 8, minute: 0))
        ..setEnd(const TimeOfDay(hour: 8, minute: 0));
      await settle();
      p.toggle(tan);
      expect(await p.submit(), isNull);
      final saved = verify(() => add(captureAny())).captured.single as Duty;
      expect(saved.start, DateTime(2023, 7, 7, 8));
      expect(saved.points, 1.5);
      expect(saved.participants, {'Tan Ah Kow': 'CPL'});
      p.dispose();
    });

    test('update starts from the duty and sends previous + updated', () async {
      final existing = buildDuty();
      final p = provider(initial: existing);
      await settle();
      expect(p.participants, existing.participants);
      p.toggle(lim);
      expect(await p.submit(), isNull);
      final params = verify(() => update(captureAny())).captured.single
          as UpdateDutyParams;
      expect(params.previous, existing);
      expect(
          params.updated.participants, {'Tan Ah Kow': 'CPL', 'Lim Bah': 'PTE'});
      p.dispose();
    });
  });

  group('DutyFormPage', () {
    Future<void> pumpForm(WidgetTester tester,
        {Duty? initial,
        AddDuty? addDuty,
        ThemeMode mode = ThemeMode.dark}) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => provider(initial: initial, addDuty: addDuty),
                  child: const DutyFormPage(),
                ),
              )),
              child: const Text('open'),
            ),
          ),
        ),
        mode: mode,
        clock: clock,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Future<void> tapKey(WidgetTester tester, String key) async {
      final f = find.byKey(Key(key));
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    Future<void> fillDateAndTimes(WidgetTester tester) async {
      await tapKey(tester, 'dutyDate');
      await tester.tap(
          find.descendant(of: find.byType(Dialog), matching: find.text('7')));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      for (final key in ['dutyStart', 'dutyEnd']) {
        await tapKey(tester, key);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('ten empty slots, points prompt and required fields',
        (tester) async {
      await pumpForm(tester, mode: themeModes.currentValue!);
      expect(find.text('Who is performing this duty?'), findsOneWidget);
      expect(find.text('Add details of the guard duty.'), findsOneWidget);
      for (var i = 0; i < 10; i++) {
        expect(find.byKey(Key('slot-$i')), findsOneWidget);
      }
      expect(find.text('Add soldier'), findsNWidgets(2));
      expect(find.text('Slots filled'), findsOneWidget);
      expect(find.text('0 / 10'), findsOneWidget);
      expect(find.text('Select a duty date!'), findsOneWidget);
      expect(find.textContaining('😄'), findsNothing);
      expect(find.text('EXPECTED POINTS PER PERSON'), findsOneWidget);
      for (final label in ['Date of Duty:', 'Start Time:', 'End Time:']) {
        expect(find.text(label), findsNWidgets(2), reason: 'label and hint');
      }
      await tapKey(tester, 'saveDuty');
      expect(find.text('Select a duty date'), findsOneWidget);
      expect(find.text('Select a start time'), findsOneWidget);
      expect(find.text('Select an end time'), findsOneWidget);
      expect(find.text('Details missing'), findsOneWidget);
      verifyNever(() => add(any()));
    }, variant: themeModes);

    testWidgets('the slots sit in rows of 2, 4 and 4', (tester) async {
      await pumpForm(tester);
      Offset at(int i) => tester.getTopLeft(find.byKey(Key('slot-$i')));
      double width(int i) => tester.getSize(find.byKey(Key('slot-$i'))).width;

      expect({at(0).dy, at(1).dy}, hasLength(1));
      expect({for (var i = 2; i < 6; i++) at(i).dy}, hasLength(1));
      expect({for (var i = 6; i < 10; i++) at(i).dy}, hasLength(1));
      expect(at(0).dy, lessThan(at(2).dy));
      expect(at(2).dy, lessThan(at(6).dy));
      expect(at(0).dx, at(2).dx);
      expect(at(0).dx, at(6).dx);
      expect(at(1).dx, greaterThan(at(0).dx));
      expect(width(0), greaterThan(width(2)));
      expect({width(2), width(3), width(4), width(5)}, hasLength(1));
      expect(width(0) + width(1) + 10, closeTo(4 * width(2) + 30, 0.01));
      for (var i = 0; i < 10; i++) {
        expect(tester.getSize(find.byKey(Key('slot-$i'))).height, 86);
      }
    });

    testWidgets('a failed roster load shows the error in the picker',
        (tester) async {
      when(() => roster(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Roster down')));
      await pumpForm(tester);
      await tapKey(tester, 'slot-0');
      expect(find.widgetWithText(ErrorView, 'Roster down'), findsOneWidget);
    });

    group('the picker sheet', () {
      testWidgets('is a bottom sheet, not a dialog', (tester) async {
        await pumpForm(tester);
        await tapKey(tester, 'slot-3');
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(find.byKey(const Key('sheetHandle')), findsOneWidget);
        expect(find.byType(Dialog), findsNothing);
        expect(find.text('ADD A NEW SOLDIER'), findsOneWidget);
        expect(find.text('0 of 10 selected'), findsOneWidget);
        expect(find.byKey(const Key('pickerSearch')), findsOneWidget);
        expect(find.byKey(const Key('pickerDone')), findsOneWidget);
        expect(
            find.descendant(
                of: find.byType(BottomSheet), matching: find.byType(RankPlate)),
            findsNWidgets(3));
      });

      testWidgets('uses the sheet colour in both themes', (tester) async {
        final mode = themeModes.currentValue!;
        await pumpForm(tester, mode: mode);
        await tapKey(tester, 'slot-0');
        final material = tester.widget<Material>(find
            .descendant(
                of: find.byType(BottomSheet), matching: find.byType(Material))
            .first);
        final palette =
            mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
        expect(material.color, palette.sheet);
      }, variant: themeModes);

      testWidgets('greys out ineligible soldiers and fills slots',
          (tester) async {
        await pumpForm(tester);
        await tapKey(tester, 'slot-3');
        expect(find.text('Ineligible'), findsOneWidget);
        expect(find.byIcon(Icons.radio_button_unchecked_rounded),
            findsNWidgets(2));
        await tester.tap(find.byKey(const Key('pick-Tan Ah Kow')));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
        expect(find.text('1 of 10 selected'), findsOneWidget);
        await tester.tap(find.byKey(const Key('pick-Lee Wei')));
        await tester.pumpAndSettle();
        expect(
            find.text('Lee Wei is ineligible for guard duty.'), findsOneWidget);
        expect(find.text('1 of 10 selected'), findsOneWidget);
        await tester.tap(find.byKey(const Key('pickerDone')));
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsNothing);
        expect(
            find.descendant(
                of: find.byKey(const Key('slot-0')),
                matching: find.text('Tan Ah Kow')),
            findsOneWidget);
        expect(
            find.descendant(
                of: find.byKey(const Key('slot-0')),
                matching: find.byType(RankPlate)),
            findsOneWidget);
        expect(find.text('1 / 10'), findsOneWidget);
      });

      testWidgets('an ineligible soldier names the status', (tester) async {
        when(() => roster(any())).thenAnswer((_) async => Right(DutyRoster(
            soldiers: [tan, lee, lim],
            ineligible: const {'Lee Wei'},
            reasons: const {'Lee Wei': 'OL'})));
        await pumpForm(tester);
        await tapKey(tester, 'slot-0');
        expect(find.text('Ineligible · OL'), findsOneWidget);
      });

      testWidgets('tapping a picked soldier again takes them off',
          (tester) async {
        await pumpForm(tester);
        await tapKey(tester, 'slot-0');
        await tester.tap(find.byKey(const Key('pick-Tan Ah Kow')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('pick-Tan Ah Kow')));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
        expect(find.text('0 of 10 selected'), findsOneWidget);
        await tester.tap(find.byKey(const Key('pickerDone')));
        await tester.pumpAndSettle();
        expect(find.text('Add soldier'), findsNWidgets(2));
      });

      testWidgets('the search narrows the list and starts empty each time',
          (tester) async {
        await pumpForm(tester);
        await tapKey(tester, 'slot-0');
        await tester.enterText(find.byKey(const Key('pickerSearch')), 'lim');
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('pick-Lim Bah')), findsOneWidget);
        expect(find.byKey(const Key('pick-Tan Ah Kow')), findsNothing);

        await tester.enterText(find.byKey(const Key('pickerSearch')), 'zzz');
        await tester.pumpAndSettle();
        expect(find.text('No results Found!'), findsOneWidget);

        await tester.tap(find.byKey(const Key('pickerDone')));
        await tester.pumpAndSettle();
        await tapKey(tester, 'slot-0');
        expect(find.byKey(const Key('pick-Tan Ah Kow')), findsOneWidget);
        expect(find.text('No results Found!'), findsNothing);
      });

      testWidgets('an eleventh soldier is refused with the slot message',
          (tester) async {
        when(() => roster(any())).thenAnswer((_) async => Right(DutyRoster(
            soldiers: [for (var i = 0; i < 11; i++) buildSoldier(name: 'S$i')],
            ineligible: const {})));
        await pumpForm(tester);
        await tapKey(tester, 'slot-0');
        Future<void> pick(int i) async {
          await tester.ensureVisible(find.byKey(Key('pick-S$i')));
          await tester.tap(find.byKey(Key('pick-S$i')));
          await tester.pumpAndSettle();
        }

        for (var i = 0; i < 10; i++) {
          await pick(i);
        }
        expect(find.text('10 of 10 selected'), findsOneWidget);
        await pick(10);
        expect(find.text(tooManySlots), findsOneWidget);
        expect(find.text('10 of 10 selected'), findsOneWidget);
      });
    });

    testWidgets(
        'ten picked soldiers fill every slot; narrow slots show a surname',
        (tester) async {
      when(() => roster(any()))
          .thenAnswer((_) async => Right(DutyRoster(soldiers: [
                for (var i = 0; i < 10; i++)
                  buildSoldier(name: 'Given Surname$i', rank: 'PTE'),
              ], ineligible: const {})));
      await pumpForm(tester);
      await tapKey(tester, 'slot-0');
      for (var i = 0; i < 10; i++) {
        await tester.ensureVisible(find.byKey(Key('pick-Given Surname$i')));
        await tester.tap(find.byKey(Key('pick-Given Surname$i')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('pickerDone')));
      await tester.pumpAndSettle();
      expect(
          find.descendant(
              of: find.byKey(const Key('slot-0')),
              matching: find.text('Given Surname0')),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const Key('slot-5')),
              matching: find.text('Surname5')),
          findsOneWidget);
      expect(find.text('Add soldier'), findsNothing);
      expect(find.text('10 / 10'), findsOneWidget);
    });

    testWidgets('picking a Friday prices the duty at 1.5', (tester) async {
      await pumpForm(tester);
      await fillDateAndTimes(tester);
      expect(tester.widget<Text>(find.byKey(const Key('expectedPoints'))).data,
          '1.5');
      expect(tester.widget<Text>(find.byKey(const Key('dayType'))).data,
          'Weekday (Friday) Duty');
      expect(find.textContaining('😖'), findsNothing);
    });

    testWidgets('an end time equal to the start says next day (D10)',
        (tester) async {
      await pumpForm(tester);
      expect(find.text('next day'), findsNothing);
      await fillDateAndTimes(tester);
      expect(find.text('next day'), findsOneWidget);
    });

    testWidgets('the save button stays pinned while the form scrolls',
        (tester) async {
      await pumpForm(tester);
      final button = tester.getRect(find.byKey(const Key('saveDuty')));
      expect(button.bottom, greaterThan(tester.view.physicalSize.height - 100));
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(const Key('saveDuty'))), button);
    });

    testWidgets('adding writes the duty and credits points (fake Firestore)',
        (tester) async {
      final db =
          await seedFirestore(soldiers: [SeededSoldier(soldierDoc(points: 2))]);
      final realAdd = AddDuty(DutyRepositoryImpl(DutyRemoteDataSource(db)));
      await pumpForm(tester, addDuty: realAdd);
      await tapKey(tester, 'slot-0');
      await tester.tap(find.byKey(const Key('pick-Tan Ah Kow')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pickerDone')));
      await tester.pumpAndSettle();
      await fillDateAndTimes(tester);
      await tapKey(tester, 'saveDuty');
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      final duty = (await db.collection('Duties').get()).docs.single.data();
      expect(duty['dutyDate'], '7 Jul 2023');
      expect(duty['points'], 1.5);
      expect(duty['participants'], {'Tan Ah Kow': 'CPL'});
      final user = await db.collection('Users').doc('Tan Ah Kow').get();
      expect(user.data()!['points'], 3.5);
      expect(find.text('Guard duty added successfully!'), findsOneWidget);
    });

    testWidgets('edit mode shows the stored duty and updates', (tester) async {
      await pumpForm(tester, initial: buildDuty());
      expect(find.text('Edit an existing duty.'), findsOneWidget);
      expect(find.text('7 Jul 2023'), findsOneWidget);
      await tapKey(tester, 'saveDuty');
      verify(() => update(any())).called(1);
      expect(find.text('Guard duty updated successfully!'), findsOneWidget);
    });
  });
}

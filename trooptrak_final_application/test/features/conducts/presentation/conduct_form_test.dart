import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/conducts/domain/entities/conduct.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/build_conduct_roster.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/conduct_usecases.dart';
import 'package:trooptrak_final_application/features/conducts/presentation/pages/conduct_form_page.dart';
import 'package:trooptrak_final_application/features/conducts/presentation/providers/conduct_form_provider.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/usecases/soldier_usecases.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';
import '../../../helpers/pump_app.dart';

class _MockSoldiers extends Mock implements WatchSoldiers {}

class _MockRoster extends Mock implements BuildConductRoster {}

class _MockAdd extends Mock implements AddConduct {}

class _MockUpdate extends Mock implements UpdateConduct {}

void main() {
  final clock = FixedClock(DateTime(2023, 7, 5, 9));
  final soldiers = [
    buildSoldier(name: 'Tan Ah Kow'),
    buildSoldier(name: 'Lee Wei'),
    buildSoldier(name: 'Lim Bah'),
  ];
  late _MockSoldiers watch;
  late _MockRoster roster;
  late _MockAdd add;
  late _MockUpdate update;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(buildConduct());
  });

  setUp(() {
    watch = _MockSoldiers();
    roster = _MockRoster();
    add = _MockAdd();
    update = _MockUpdate();
    when(() => watch(any())).thenAnswer(
        (_) => Stream.value(Right<Failure, List<Soldier>>(soldiers)));
    when(() => roster(any())).thenAnswer((inv) async {
      final type = inv.positionalArguments.first as String;
      return Right(type == 'Run'
          ? const ConductRoster(
              participants: ['Lim Bah'],
              reasons: {'Tan Ah Kow': 'Ex RMJ', 'Lee Wei': 'OL'})
          : const ConductRoster(
              participants: ['Tan Ah Kow', 'Lim Bah'],
              reasons: {'Lee Wei': 'OL'}));
    });
    when(() => add(any())).thenAnswer((_) async => const Right(unit));
    when(() => update(any())).thenAnswer((_) async => const Right(unit));
  });

  ConductFormProvider provider({Conduct? initial}) => ConductFormProvider(
        watchSoldiers: watch,
        buildRoster: roster,
        add: add,
        update: update,
        initial: initial,
      );

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('ConductFormProvider', () {
    test('add: roster on open (leave only), rebuilt on each type change (R5)',
        () async {
      final p = provider();
      await settle();
      expect(p.participants, ['Tan Ah Kow', 'Lim Bah']);
      expect(p.reasonFor('Lee Wei'), 'OL');

      p.setType('Run');
      await settle();
      expect(p.participants, ['Lim Bah']);
      expect(p.reasonFor('Tan Ah Kow'), 'Ex RMJ');
      verify(() => roster('')).called(1);
      verify(() => roster('Run')).called(1);
      p.dispose();
    });

    test('manual remove reads "Removed from conduct"; add back clears it',
        () async {
      final p = provider();
      await settle();
      p.toggle('Lim Bah');
      expect(p.isParticipating('Lim Bah'), isFalse);
      expect(p.reasonFor('Lim Bah'), Conduct.removedReason);
      p.toggle('Lim Bah');
      expect(p.reasonFor('Lim Bah'), isNull);
      p.dispose();
    });

    test('update keeps stored participants and reasons; no roster rebuild',
        () async {
      final existing = buildConduct(
          participants: ['Lee Wei'], soldierReason: {'Tan Ah Kow': 'Ex RMJ'});
      final p = provider(initial: existing);
      p.setType('IPPT');
      await settle();
      expect(p.participants, ['Lee Wei']);
      expect(p.reasonFor('Tan Ah Kow'), 'Ex RMJ');
      verifyNever(() => roster(any()));

      expect(await p.submit('Morning Run'), isNull);
      verify(() => update(existing.copyWith(type: 'IPPT'))).called(1);
      p.dispose();
    });

    test('submit combines the date with both times and reports failures',
        () async {
      final p = provider()
        ..setType('Run')
        ..setDate(DateTime(2023, 7, 6))
        ..setStart(const TimeOfDay(hour: 7, minute: 30))
        ..setEnd(const TimeOfDay(hour: 9, minute: 0));
      await settle();
      expect(await p.submit('5km'), isNull);
      final saved = verify(() => add(captureAny())).captured.single as Conduct;
      expect(saved.start, DateTime(2023, 7, 6, 7, 30));
      expect(saved.end, DateTime(2023, 7, 6, 9));
      expect(saved.participants, ['Lim Bah']);
      expect(saved.soldierReason, {'Tan Ah Kow': 'Ex RMJ', 'Lee Wei': 'OL'});

      when(() => add(any())).thenAnswer(
          (_) async => const Left(ValidationFailure(endBeforeStartTime)));
      expect(await p.submit('5km'), endBeforeStartTime);
      p.dispose();
    });

    test('search filters the participant list by name', () async {
      final p = provider();
      await settle();
      p.search('LEE');
      expect(p.visibleSoldiers.map((s) => s.name), ['Lee Wei']);
      p.dispose();
    });
  });

  group('ConductFormPage', () {
    Future<void> pumpForm(WidgetTester tester,
        {Conduct? initial, ThemeMode mode = ThemeMode.dark}) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => provider(initial: initial),
                  child: const ConductFormPage(),
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

    Future<void> save(WidgetTester tester) async {
      final button = find.byKey(const Key('saveConduct'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    Future<void> tapField(WidgetTester tester, String key) async {
      final field = find.byKey(Key(key));
      await tester.ensureVisible(field);
      await tester.pumpAndSettle();
      await tester.tap(field);
      await tester.pumpAndSettle();
    }

    testWidgets('empty submit lists every missing field (K21)', (tester) async {
      await pumpForm(tester, mode: themeModes.currentValue!);
      expect(find.text('Add a new conduct ✍️'), findsOneWidget);
      await save(tester);
      for (final message in [
        'Bruh select!',
        'Oi can add conduct please?',
        'Select a date',
        'Select a start time',
        'Select an end time',
      ]) {
        await tester.ensureVisible(find.text(message));
        expect(find.text(message), findsOneWidget, reason: message);
      }
      expect(find.text('Details missing'), findsOneWidget);
      verifyNever(() => add(any()));
    }, variant: themeModes);

    testWidgets('rows show ADD/REMOVE and the exclusion reason',
        (tester) async {
      await pumpForm(tester);
      expect(find.text('OL'), findsOneWidget);
      final toggle = find.byKey(const Key('toggle-Lim Bah'));
      await tester.ensureVisible(toggle);
      expect(find.descendant(of: toggle, matching: find.text('REMOVE')),
          findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.descendant(of: toggle, matching: find.text('ADD')),
          findsOneWidget);
      expect(find.text('Removed from conduct'), findsOneWidget);
    });

    testWidgets('a complete form adds the conduct and returns', (tester) async {
      await pumpForm(tester);
      await tapField(tester, 'conductType');
      await tester.tap(find.text('Run').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('conductName')), '5km run');
      await tapField(tester, 'conductDate');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      for (final key in ['startTime', 'endTime']) {
        await tapField(tester, key);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }
      await save(tester);

      final saved = verify(() => add(captureAny())).captured.single as Conduct;
      expect(saved.name, '5km run');
      expect(saved.type, 'Run');
      expect(saved.start, DateTime(2023, 7, 5, 9));
      expect(saved.participants, ['Lim Bah']);
      expect(find.text('Conduct added successfully!'), findsOneWidget);
      expect(find.byType(ConductFormPage), findsNothing);
    });

    testWidgets('edit mode is prefilled and saves through update',
        (tester) async {
      await pumpForm(tester, initial: buildConduct());
      expect(find.text('Edit conduct ✍️'), findsOneWidget);
      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('5 Jul 2023'), findsOneWidget);
      expect(find.text('7:00 AM'), findsOneWidget);
      await save(tester);
      verify(() => update(buildConduct())).called(1);
      expect(find.text('Conduct updated successfully!'), findsOneWidget);
    });
  });
}

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/core/widgets/primary_button.dart';
import 'package:trooptrak_final_application/core/widgets/rank_chip.dart';
import 'package:trooptrak_final_application/core/widgets/rank_plate.dart';
import 'package:trooptrak_final_application/core/widgets/state_tone.dart';
import 'package:trooptrak_final_application/core/widgets/sticky_cta_bar.dart';
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

    test('ticks cover the whole roster, nothing until it loads', () async {
      final p = provider();
      expect(p.ticks.total, 0);
      await settle();
      expect(p.ticks.ticks.map((t) => t.soldier.name),
          ['Tan Ah Kow', 'Lee Wei', 'Lim Bah']);
      expect(p.ticks.ticks.map((t) => t.tookPart), [true, false, true]);
      expect(p.ticks.participating, 2);
      p.dispose();
    });

    test('ticks follow toggles and type changes and ignore the search',
        () async {
      final p = provider();
      await settle();
      p.toggle('Lim Bah');
      expect(p.ticks.participating, 1);
      p.toggle('Lee Wei');
      expect(p.ticks.participating, 2);
      p.search('lee');
      expect(p.ticks.total, 3);
      p.setType('Run');
      await settle();
      expect([p.ticks.participating, p.ticks.total], [1, 3]);
      p.dispose();
    });

    test('ticks of an edited conduct start from its stored participants',
        () async {
      final p = provider(initial: buildConduct(participants: ['Lee Wei']));
      await settle();
      expect(p.ticks.ticks.map((t) => t.tookPart), [false, true, false]);
      p.dispose();
    });

    test('noteFor: the appointment when added, the reason when left out',
        () async {
      final p = provider();
      await settle();
      expect(p.noteFor(soldiers[0]), 'Section IC');
      expect(p.noteFor(soldiers[1]), 'OL');
      p.toggle('Tan Ah Kow');
      expect(p.noteFor(soldiers[0]), Conduct.removedReason);
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

    testWidgets('a failed soldier stream shows the error in the roster',
        (tester) async {
      when(() => watch(any())).thenAnswer((_) => Stream.value(
          const Left<Failure, List<Soldier>>(ServerFailure('Roll offline'))));
      await pumpForm(tester);
      final error = find.widgetWithText(ErrorView, 'Roll offline');
      await tester.ensureVisible(error);
      expect(error, findsOneWidget);
    });

    testWidgets('empty submit lists every missing field (K21)', (tester) async {
      await pumpForm(tester, mode: themeModes.currentValue!);
      expect(find.text('Add a new conduct'), findsOneWidget);
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

    testWidgets('no emoji in the titles (D11)', (tester) async {
      await pumpForm(tester);
      expect(find.textContaining('✍'), findsNothing);
    });

    testWidgets('each field has its label above it', (tester) async {
      await pumpForm(tester);
      expect(find.text('Details of the conduct'), findsOneWidget);
      for (final (label, key) in [
        ('Conduct type', 'conductType'),
        ('Enter Conduct Name:', 'conductName'),
        ('Date:', 'conductDate'),
        ('Start Time:', 'startTime'),
        ('End Time:', 'endTime'),
      ]) {
        final labelTop = tester.getTopLeft(find.text(label).first).dy;
        final fieldTop = tester.getTopLeft(find.byKey(Key(key))).dy;
        expect(labelTop, lessThanOrEqualTo(fieldTop + 1), reason: label);
      }
    });

    testWidgets('start and end time sit side by side, sharing the width',
        (tester) async {
      await pumpForm(tester);
      final start = tester.getRect(find.byKey(const Key('startTime')));
      final end = tester.getRect(find.byKey(const Key('endTime')));
      expect(start.top, end.top);
      expect(start.right, lessThan(end.left));
      expect(start.width, closeTo(end.width, 0.5));
      final date = tester.getRect(find.byKey(const Key('conductDate')));
      expect(date.width, closeTo(end.right - start.left, 0.5));
    });

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

    testWidgets('a row has plate, name, rank chip and appointment or reason',
        (tester) async {
      await pumpForm(tester, mode: themeModes.currentValue!);
      Finder inRow(String name, Finder matching) => find.descendant(
          of: find.byKey(Key('participant-$name')), matching: matching);
      expect(inRow('Tan Ah Kow', find.byType(RankPlate)), findsOneWidget);
      expect(inRow('Tan Ah Kow', find.text('Tan Ah Kow')), findsOneWidget);
      expect(inRow('Tan Ah Kow', find.byType(RankChip)), findsOneWidget);
      expect(inRow('Tan Ah Kow', find.text('Section IC')), findsOneWidget);
      expect(inRow('Lee Wei', find.text('OL')), findsOneWidget);
      expect(inRow('Lee Wei', find.text('Section IC')), findsNothing);
    }, variant: themeModes);

    testWidgets('ADD and REMOVE are compact tonal pills in green and red',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      await pumpForm(tester, mode: mode);
      for (final (name, label, tone) in [
        ('Lim Bah', 'REMOVE', StateTone.leave),
        ('Lee Wei', 'ADD', StateTone.inCamp),
      ]) {
        final toggle = find.byKey(Key('toggle-$name'));
        await tester.ensureVisible(toggle);
        final button = tester.widget<PrimaryButton>(
            find.descendant(of: toggle, matching: find.byType(PrimaryButton)));
        expect(button.label, label);
        expect(button.style, PrimaryButtonStyle.tonal);
        expect(button.compact, isTrue);
        expect(button.tone, tone);
        expect(tester.getSize(toggle).height, 32);
        final decoration = tester
            .widget<DecoratedBox>(find
                .descendant(of: toggle, matching: find.byType(DecoratedBox))
                .first)
            .decoration as ShapeDecoration;
        expect(decoration.color, tone.tint(palette));
        final text = tester.widget<Text>(
            find.descendant(of: toggle, matching: find.text(label)));
        expect(text.style!.color, tone.text(palette));
      }
    }, variant: themeModes);

    group('Added strip', () {
      Color tickColor(WidgetTester tester, int index) => (tester
              .widget<AnimatedContainer>(find.byKey(ValueKey('tick-0-$index')))
              .decoration! as BoxDecoration)
          .color!;

      testWidgets('one tick per soldier: added is accent, not added is grey',
          (tester) async {
        final mode = themeModes.currentValue!;
        final palette =
            mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
        await pumpForm(tester, mode: mode);
        expect(find.text('Added'), findsOneWidget);
        expect(find.text('2 / 3'), findsOneWidget);
        expect(find.byKey(const ValueKey('tick-0-2')), findsOneWidget);
        expect(find.byKey(const ValueKey('tick-0-3')), findsNothing);
        expect([
          for (var i = 0; i < 3; i++) tickColor(tester, i)
        ], [
          StateTone.accent.fill(palette),
          StateTone.out.fill(palette),
          StateTone.accent.fill(palette),
        ]);
      }, variant: themeModes);

      testWidgets('ADD and REMOVE update the count and the tick live',
          (tester) async {
        final palette = AppPalette.dark;
        await pumpForm(tester);
        await tester.ensureVisible(find.byKey(const Key('toggle-Lee Wei')));
        await tester.tap(find.byKey(const Key('toggle-Lee Wei')));
        await tester.pumpAndSettle();
        expect(find.text('3 / 3'), findsOneWidget);
        expect(tickColor(tester, 1), StateTone.accent.fill(palette));

        await tester.tap(find.byKey(const Key('toggle-Tan Ah Kow')));
        await tester.tap(find.byKey(const Key('toggle-Lim Bah')));
        await tester.pumpAndSettle();
        expect(find.text('1 / 3'), findsOneWidget);
        expect(tickColor(tester, 0), StateTone.out.fill(palette));
        expect(tickColor(tester, 2), StateTone.out.fill(palette));
      });

      testWidgets('changing the type refills the strip (R5)', (tester) async {
        await pumpForm(tester);
        expect(find.text('2 / 3'), findsOneWidget);
        await tapField(tester, 'conductType');
        await tester.tap(find.text('Run').last);
        await tester.pumpAndSettle();
        expect(find.text('1 / 3'), findsOneWidget);
      });

      testWidgets('a long press names the soldier and the part played',
          (tester) async {
        await pumpForm(tester);
        await tester.longPress(find.byKey(const ValueKey('tick-0-1')));
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('CPL Lee Wei · not participating'), findsOneWidget);
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      });

      testWidgets('editing starts from the stored participants',
          (tester) async {
        await pumpForm(tester,
            initial: buildConduct(participants: ['Lee Wei']));
        expect(find.text('1 / 3'), findsOneWidget);
        expect(find.text('Auto-filled from statuses'), findsNothing);
      });

      testWidgets('the add form says the list is auto-filled', (tester) async {
        await pumpForm(tester);
        expect(find.text('Add Participants'), findsOneWidget);
        expect(find.text('Auto-filled from statuses'), findsOneWidget);
      });

      testWidgets('is hidden when the roster fails to load', (tester) async {
        when(() => watch(any())).thenAnswer((_) => Stream.value(
            const Left<Failure, List<Soldier>>(ServerFailure('Roll offline'))));
        await pumpForm(tester);
        expect(find.text('Added'), findsNothing);
        expect(find.byKey(const ValueKey('tick-0-0')), findsNothing);
      });
    });

    group('participant search', () {
      Future<void> search(WidgetTester tester, String text) async {
        final field = find.byKey(const Key('participantSearch'));
        await tester.ensureVisible(field);
        await tester.enterText(field, text);
        await tester.pumpAndSettle();
      }

      testWidgets('narrows the rows by name and keeps counting everyone',
          (tester) async {
        await pumpForm(tester);
        await search(tester, 'lee');
        expect(find.byKey(const Key('participant-Lee Wei')), findsOneWidget);
        expect(find.byKey(const Key('participant-Tan Ah Kow')), findsNothing);
        expect(find.byKey(const Key('participant-Lim Bah')), findsNothing);
        expect(find.text('2 / 3'), findsOneWidget);
        expect(find.byKey(const ValueKey('tick-0-2')), findsOneWidget);
      });

      testWidgets('a toggle made while searching is kept', (tester) async {
        await pumpForm(tester);
        await search(tester, 'lee');
        await tester.tap(find.byKey(const Key('toggle-Lee Wei')));
        await tester.pumpAndSettle();
        expect(find.text('3 / 3'), findsOneWidget);
        await search(tester, '');
        expect(find.byKey(const Key('participant-Tan Ah Kow')), findsOneWidget);
        expect(find.text('3 / 3'), findsOneWidget);
      });

      testWidgets('no match shows the empty text', (tester) async {
        await pumpForm(tester);
        await search(tester, 'zzz');
        expect(find.byType(EmptyState), findsOneWidget);
        expect(find.text('No results Found!'), findsOneWidget);
        expect(find.byKey(const Key('participant-Lee Wei')), findsNothing);
      });
    });

    group('save bar', () {
      testWidgets('ADD NEW CONDUCT is pinned below the scrolling form',
          (tester) async {
        await pumpForm(tester);
        final button = find.byKey(const Key('saveConduct'));
        expect(find.text('ADD NEW CONDUCT'), findsOneWidget);
        expect(
            find.descendant(
                of: find.byType(SingleChildScrollView), matching: button),
            findsNothing);
        expect(find.descendant(of: find.byType(StickyCtaBar), matching: button),
            findsOneWidget);
        expect(tester.getRect(button).bottom,
            lessThanOrEqualTo(tester.view.physicalSize.height));
        expect(tester.getRect(button).height, 50);
      });

      testWidgets('stays below the last row after scrolling to it',
          (tester) async {
        await pumpForm(tester);
        await tester.ensureVisible(find.byKey(const Key('toggle-Lim Bah')));
        await tester.pumpAndSettle();
        expect(
            tester.getRect(find.byKey(const Key('toggle-Lim Bah'))).bottom,
            lessThanOrEqualTo(
                tester.getRect(find.byKey(const Key('saveConduct'))).top));
      });

      testWidgets('the label follows add and edit', (tester) async {
        await pumpForm(tester, initial: buildConduct());
        expect(find.text('EDIT CONDUCT DETAILS'), findsOneWidget);
        expect(find.text('ADD NEW CONDUCT'), findsNothing);
      });
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
      expect(find.text('Edit conduct'), findsOneWidget);
      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('5 Jul 2023'), findsOneWidget);
      expect(find.text('7:00 AM'), findsOneWidget);
      await save(tester);
      verify(() => update(buildConduct())).called(1);
      expect(find.text('Conduct updated successfully!'), findsOneWidget);
    });
  });
}

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/core/widgets/state_tone.dart';
import 'package:trooptrak_final_application/features/conducts/domain/entities/conduct.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/conduct_usecases.dart';
import 'package:trooptrak_final_application/features/conducts/presentation/conducts_routes.dart';
import 'package:trooptrak_final_application/features/conducts/presentation/pages/conduct_tracker_page.dart';
import 'package:trooptrak_final_application/features/conducts/presentation/providers/conduct_tracker_provider.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/usecases/soldier_usecases.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';
import '../../../helpers/pump_app.dart';

class _MockOnDay extends Mock implements WatchConductsOnDay {}

class _MockSoldiers extends Mock implements WatchSoldiers {}

void main() {
  final clock = FixedClock(DateTime(2023, 7, 5, 9));
  final run = buildConduct(
      id: 'run', name: 'Morning Run', participants: ['A', 'B', 'C']);
  final ippt = buildConduct(
      id: 'ippt',
      name: 'IPPT',
      type: 'IPPT',
      participants: ['A'],
      soldierReason: {'B': 'Ex Boots'});
  final tomorrow = buildConduct(
      id: 'rm',
      name: 'Route March',
      type: 'Route March',
      start: DateTime(2023, 7, 6, 20),
      end: DateTime(2023, 7, 6, 23));

  late _MockOnDay onDay;
  late _MockSoldiers soldiers;
  final requested = <DateTime>[];

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    requested.clear();
    onDay = _MockOnDay();
    soldiers = _MockSoldiers();
    when(() => onDay(any())).thenAnswer((inv) {
      final day = inv.positionalArguments.first as DateTime;
      requested.add(day);
      final list = day.day == 5
          ? [run, ippt]
          : day.day == 6
              ? [tomorrow]
              : <Conduct>[];
      return Stream.value(Right<Failure, List<Conduct>>(list));
    });
    when(() => soldiers(any()))
        .thenAnswer((_) => Stream.value(Right<Failure, List<Soldier>>([
              for (final name in [
                'A',
                'B',
                'C',
                for (var i = 3; i < 10; i++) 'S$i'
              ])
                buildSoldier(name: name),
            ])));
  });

  ConductTrackerProvider provider({String? participant}) =>
      ConductTrackerProvider(
          watchOnDay: onDay,
          watchSoldiers: soldiers,
          clock: clock,
          participant: participant);

  group('ConductTrackerProvider', () {
    test('starts on today, filters by day and resubscribes on change (R13)',
        () async {
      final p = provider();
      await Future<void>.delayed(Duration.zero);
      expect(p.day, DateTime(2023, 7, 5));
      expect(p.conducts.dataOrNull, [run, ippt]);

      p.selectDay(DateTime(2023, 7, 6, 15));
      expect(p.conducts.isLoading, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(p.conducts.dataOrNull, [tomorrow]);

      p.selectDay(DateTime(2023, 7, 6, 18));
      expect(requested, [DateTime(2023, 7, 5), DateTime(2023, 7, 6)]);
      p.dispose();
    });

    test('participation is tracked only for a named soldier (R13)', () {
      final commander = provider();
      expect(commander.isParticipating(run), isNull);
      commander.dispose();

      final soldier = provider(participant: 'B');
      expect(soldier.isParticipating(run), isTrue);
      expect(soldier.isParticipating(ippt), isFalse);
      soldier.dispose();
    });

    test('range runs from 2022 to a year after today', () {
      final p = provider();
      expect(p.firstDay, DateTime(2022));
      expect(p.lastDay, DateTime(2024, 7, 5));
      p.dispose();
    });

    group('tick data', () {
      final roster = [
        for (final n in ['A', 'B', 'C', 'D']) buildSoldier(name: n)
      ];

      void rosterIs(List<Soldier> list) => when(() => soldiers(any()))
          .thenAnswer((_) => Stream.value(Right<Failure, List<Soldier>>(list)));

      test('keeps the roster in the order it arrives', () async {
        rosterIs(roster);
        final p = provider();
        expect(p.roster, isEmpty);
        await Future<void>.delayed(Duration.zero);
        expect(p.roster, roster);
        p.dispose();
      });

      test('a failed roster stream keeps the last good roster', () async {
        final controller = StreamController<Either<Failure, List<Soldier>>>();
        when(() => soldiers(any())).thenAnswer((_) => controller.stream);
        final p = provider();
        controller.add(Right(roster));
        await Future<void>.delayed(Duration.zero);
        controller.add(const Left(ServerFailure('Roster down')));
        await Future<void>.delayed(Duration.zero);
        expect(p.roster, roster);
        p.dispose();
        await controller.close();
      });

      test('ticksFor marks who took part, one tick per rostered soldier',
          () async {
        rosterIs(roster);
        final p = provider();
        await Future<void>.delayed(Duration.zero);

        final ticks = p.ticksFor(run);
        expect(ticks.ticks.map((t) => t.soldier), roster);
        expect(ticks.ticks.map((t) => t.tookPart), [true, true, true, false]);
        expect(ticks.participating, 3);
        expect(ticks.total, 4);
        expect(ticks.self, isNull);
        p.dispose();
      });

      test('ticksFor marks the signed-in soldier, who took part or not',
          () async {
        rosterIs(roster);
        final p = provider(participant: 'B');
        await Future<void>.delayed(Duration.zero);

        expect(p.ticksFor(run).self?.soldier.name, 'B');
        expect(p.ticksFor(run).self?.tookPart, isTrue);
        expect(p.ticksFor(ippt).self?.soldier.name, 'B');
        expect(p.ticksFor(ippt).self?.tookPart, isFalse);
        p.dispose();
      });

      test('ticksFor is empty until the roster arrives', () {
        rosterIs(roster);
        final p = provider();
        expect(p.ticksFor(run).ticks, isEmpty);
        p.dispose();
      });

      test('listeners are told when the roster arrives', () async {
        rosterIs(roster);
        final p = provider();
        var notified = 0;
        p.addListener(() => notified++);
        await Future<void>.delayed(Duration.zero);
        expect(notified, greaterThan(0));
        p.dispose();
      });
    });
  });

  Future<RouteRecorder> pumpTracker(WidgetTester tester,
      {bool canManage = true,
      ThemeMode mode = ThemeMode.dark,
      Widget Function(BuildContext context)? tab}) async {
    final recorder = RouteRecorder();
    await tester.pumpApp(
      Scaffold(
        body: tab != null
            ? Builder(builder: tab)
            : ChangeNotifierProvider(
                create: (_) => provider(),
                child: ConductTrackerPage(canManage: canManage),
              ),
      ),
      providers: [
        Provider<WatchConductsOnDay>.value(value: onDay),
        Provider<WatchSoldiers>.value(value: soldiers),
      ],
      mode: mode,
      clock: clock,
      observers: [recorder],
    );
    await tester.pumpAndSettle();
    return recorder;
  }

  Finder inCard(String id, Finder finder) =>
      find.descendant(of: find.byKey(Key('conduct-$id')), matching: finder);

  bool isSelfRing(Widget w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.endsWith('-self');

  Finder ticksIn(String id) => inCard(
      id,
      find.byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          RegExp(r'^tick-0-\d+$')
              .hasMatch((w.key! as ValueKey<String>).value)));

  Color tickColor(WidgetTester tester, String id, int index) => (tester
          .widget<AnimatedContainer>(
              inCard(id, find.byKey(ValueKey('tick-0-$index'))))
          .decoration! as BoxDecoration)
      .color!;

  Future<void> longPressTick(WidgetTester tester, String id, int index) async {
    await tester.longPress(inCard(id, find.byKey(ValueKey('tick-0-$index'))));
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> letTooltipGo(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  group('ConductTrackerPage', () {
    testWidgets('heads the day with the date, Today and the date strip',
        (tester) async {
      await pumpTracker(tester, mode: themeModes.currentValue!);
      expect(find.text('July 5, 2023'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byKey(const Key('pickConductDay')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('date-strip-5 Jul 2023')), findsOneWidget);
      expect(find.text('Conduct Tracker'), findsNothing);
    }, variant: themeModes);

    testWidgets('lists a card per conduct under the section header',
        (tester) async {
      await pumpTracker(tester, mode: themeModes.currentValue!);
      expect(find.text('Conducts Completed / Ongoing'), findsOneWidget);
      expect(find.text('2 today'), findsOneWidget);
      expect(find.text('Participation Strength'), findsNothing);
      expect(find.byKey(const Key('conduct-run')), findsOneWidget);
      expect(find.byKey(const Key('conduct-ippt')), findsOneWidget);
    }, variant: themeModes);

    testWidgets('a card shows type, name, time, count badge and caption',
        (tester) async {
      await pumpTracker(tester, mode: themeModes.currentValue!);
      expect(inCard('run', find.text('RUN')), findsOneWidget);
      expect(inCard('run', find.text('Morning Run')), findsOneWidget);
      expect(inCard('run', find.text('7:00 AM – 8:00 AM')), findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const Key('count-run')), matching: find.text('3')),
          findsOneWidget);
      expect(
          inCard('run', find.text('Participation strength')), findsOneWidget);
      expect(inCard('run', find.textContaining('3 / 10')), findsOneWidget);

      expect(
          find.descendant(
              of: find.byKey(const Key('count-ippt')),
              matching: find.text('1')),
          findsOneWidget);
      expect(inCard('ippt', find.textContaining('1 / 10')), findsOneWidget);
    }, variant: themeModes);

    testWidgets('the commander side has no tick or cross marks',
        (tester) async {
      await pumpTracker(tester);
      expect(find.byKey(const Key('participating-run')), findsNothing);
      expect(find.byKey(const Key('notParticipating-run')), findsNothing);
    });

    testWidgets('a strip tick per soldier: accent for took part, grey if not',
        (tester) async {
      final mode = themeModes.currentValue!;
      await pumpTracker(tester, mode: mode);
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      expect(ticksIn('run'), findsNWidgets(10));
      expect(ticksIn('ippt'), findsNWidgets(10));

      for (final index in [0, 1, 2]) {
        expect(tickColor(tester, 'run', index), StateTone.accent.fill(palette));
      }
      for (final index in [3, 9]) {
        expect(tickColor(tester, 'run', index), StateTone.out.fill(palette));
      }
      expect(tickColor(tester, 'ippt', 0), StateTone.accent.fill(palette));
      expect(tickColor(tester, 'ippt', 1), StateTone.out.fill(palette));
    }, variant: themeModes);

    testWidgets('the commander strip has no self ring', (tester) async {
      await pumpTracker(tester);
      expect(find.byWidgetPredicate(isSelfRing), findsNothing);
    });

    testWidgets('a long press on a tick names the soldier and their part',
        (tester) async {
      await pumpTracker(tester);
      await longPressTick(tester, 'run', 0);
      expect(find.text('CPL A · participating'), findsOneWidget);
      await letTooltipGo(tester);

      await longPressTick(tester, 'run', 3);
      expect(find.text('CPL S3 · not participating'), findsOneWidget);
      await letTooltipGo(tester);
    });

    testWidgets('tapping another day on the strip updates the list',
        (tester) async {
      await pumpTracker(tester);
      await tester.tap(find.byKey(const ValueKey('date-strip-6 Jul 2023')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('conduct-rm')), findsOneWidget);
      expect(find.byKey(const Key('conduct-run')), findsNothing);
    });

    testWidgets('a day without conducts shows the empty icon and text',
        (tester) async {
      await pumpTracker(tester);
      await tester.tap(find.byKey(const ValueKey('date-strip-7 Jul 2023')));
      await tester.pumpAndSettle();
      expect(find.text('NO CONDUCTS FOR TODAY!'), findsOneWidget);
      expect(find.byIcon(Icons.event_busy_rounded), findsOneWidget);
    });

    testWidgets('a failed conduct stream shows the error', (tester) async {
      when(() => onDay(any())).thenAnswer((_) => Stream.value(
          const Left<Failure, List<Conduct>>(ServerFailure('Conducts down'))));
      await pumpTracker(tester);
      expect(find.widgetWithText(ErrorView, 'Conducts down'), findsOneWidget);
      expect(find.byKey(const Key('conduct-run')), findsNothing);
    });

    testWidgets('tiles open the conduct details by id', (tester) async {
      final recorder = await pumpTracker(tester);
      final tile = find.byKey(const Key('conduct-ippt'));
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.conductDetails);
      expect(recorder.lastArguments, 'ippt');
    });

    testWidgets('Add Conduct only for commanders', (tester) async {
      final recorder = await pumpTracker(tester);
      await tester.tap(find.byKey(const Key('addConduct')));
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.addConduct);
    });

    testWidgets('read-only tracker has no Add Conduct', (tester) async {
      await pumpTracker(tester, canManage: false);
      expect(find.byKey(const Key('addConduct')), findsNothing);
    });
  });

  group('soldier conduct tracker tab', () {
    Future<RouteRecorder> pumpSoldier(WidgetTester tester,
            {ThemeMode mode = ThemeMode.dark}) =>
        pumpTracker(tester,
            mode: mode,
            tab: (context) => soldierConductTrackerTab(context, 'B'));

    testWidgets('has a title and no Add Conduct; badges show participation',
        (tester) async {
      await pumpSoldier(tester, mode: themeModes.currentValue!);
      expect(find.text('Conduct Tracker'), findsOneWidget);
      expect(find.byKey(const Key('addConduct')), findsNothing);
      expect(find.byKey(const Key('participating-run')), findsOneWidget);
      expect(find.byKey(const Key('notParticipating-run')), findsNothing);
      expect(find.byKey(const Key('notParticipating-ippt')), findsOneWidget);
      expect(find.byKey(const Key('participating-ippt')), findsNothing);
      expect(find.byKey(const Key('count-run')), findsNothing);
      expect(find.byKey(const Key('count-ippt')), findsNothing);
    }, variant: themeModes);

    testWidgets('the badge is a tick when taking part and a cross when not',
        (tester) async {
      await pumpSoldier(tester);
      expect(
          find.descendant(
              of: find.byKey(const Key('participating-run')),
              matching: find.byIcon(Icons.check_rounded)),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const Key('notParticipating-ippt')),
              matching: find.byIcon(Icons.close_rounded)),
          findsOneWidget);
    });

    testWidgets('the caption says you take part, or why you do not',
        (tester) async {
      await pumpSoldier(tester);
      expect(inCard('run', find.text('You are participating')), findsOneWidget);
      expect(inCard('run', find.textContaining('3 / 10')), findsOneWidget);
      expect(inCard('ippt', find.text('Not participating · Ex Boots')),
          findsOneWidget);
      expect(inCard('ippt', find.textContaining('1 / 10')), findsOneWidget);
    });

    testWidgets('without a recorded reason the caption says removed',
        (tester) async {
      await pumpSoldier(tester);
      await tester.tap(find.byKey(const ValueKey('date-strip-6 Jul 2023')));
      await tester.pumpAndSettle();
      expect(
          inCard(
              'rm', find.text('Not participating · ${Conduct.removedReason}')),
          findsOneWidget);
    });

    testWidgets('only your own tick is ringed, taking part or not',
        (tester) async {
      await pumpSoldier(tester, mode: ThemeMode.light);
      for (final id in ['run', 'ippt']) {
        expect(inCard(id, find.byKey(const ValueKey('tick-0-1-self'))),
            findsOneWidget);
        expect(inCard(id, find.byWidgetPredicate(isSelfRing)), findsOneWidget);
        expect(ticksIn(id), findsNWidgets(10));
      }
      expect(
          tickColor(tester, 'run', 1), StateTone.accent.fill(AppPalette.light));
      expect(
          tickColor(tester, 'ippt', 1), StateTone.out.fill(AppPalette.light));
    });

    testWidgets('tiles open the read-only details', (tester) async {
      final recorder = await pumpSoldier(tester);
      final tile = find.byKey(const Key('conduct-run'));
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.conductDetailsReadOnly);
      expect(recorder.lastArguments, 'run');
    });

    testWidgets('the commander tab keeps numbers and Add Conduct',
        (tester) async {
      await pumpTracker(tester, tab: conductTrackerTab);
      expect(find.text('Conduct Tracker'), findsNothing);
      expect(find.byKey(const Key('addConduct')), findsOneWidget);
      expect(find.byKey(const Key('participating-run')), findsNothing);
      expect(find.byKey(const Key('count-run')), findsOneWidget);
    });
  });
}

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/di/calendar_event_adapter.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/core/widgets/gradient_header.dart';
import 'package:trooptrak_final_application/features/conducts/domain/entities/conduct.dart';
import 'package:trooptrak_final_application/features/conducts/domain/repositories/conduct_repository.dart';
import 'package:trooptrak_final_application/features/dashboard/domain/entities/calendar_event.dart';
import 'package:trooptrak_final_application/features/dashboard/domain/entities/strength_summary.dart';
import 'package:trooptrak_final_application/features/dashboard/domain/usecases/watch_calendar_events.dart';
import 'package:trooptrak_final_application/features/dashboard/domain/usecases/watch_strength_summary.dart';
import 'package:trooptrak_final_application/features/dashboard/presentation/dashboard_routes.dart';
import 'package:trooptrak_final_application/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/entities/duty.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/repositories/duty_repository.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_roster.dart';

import '../../helpers/builders.dart';
import '../../helpers/fake_clock.dart';
import '../../helpers/pump_app.dart';

class _MockSummary extends Mock implements WatchStrengthSummary {}

class _MockEvents extends Mock implements WatchCalendarEvents {}

class _MockConducts extends Mock implements ConductRepository {}

class _MockDuties extends Mock implements DutyRepository {}

void main() {
  final clock = FixedClock(DateTime(2023, 7, 5, 9, 30));
  final lt = buildSoldier(name: 'Lt Lee', rank: '2LT');
  final cpt = buildSoldier(name: 'Cpt Ong', rank: 'CPT', isInCamp: false);
  final cpl = buildSoldier(name: 'Cpl Tan', rank: 'CPL');
  final summary = StrengthSummary(
      entries: paradeRoster(
          [lt, cpt, cpl], [buildStatus(soldierId: 'Cpl Tan')], clock.now()));
  final run = CalendarEvent(
      title: 'Run',
      start: DateTime(2023, 7, 5, 7),
      end: DateTime(2023, 7, 5, 8),
      kind: CalendarEventKind.conduct);
  final duty = CalendarEvent(
      title: 'Guard Duty',
      start: DateTime(2023, 7, 7, 8),
      end: DateTime(2023, 7, 8, 8),
      kind: CalendarEventKind.guardDuty);

  group('calendar domain', () {
    test('an end not after the start runs into the next day', () {
      final start = DateTime(2023, 7, 5, 20);
      expect(CalendarEvent.endFor(start, DateTime(2023, 7, 5, 8)),
          DateTime(2023, 7, 6, 8));
      expect(CalendarEvent.endFor(start, start), DateTime(2023, 7, 6, 20));
      expect(CalendarEvent.endFor(start, DateTime(2023, 7, 5, 22)),
          DateTime(2023, 7, 5, 22));
    });

    test('events compare by value', () {
      expect(
          run,
          CalendarEvent(
              title: 'Run',
              start: DateTime(2023, 7, 5, 7),
              end: DateTime(2023, 7, 5, 8),
              kind: CalendarEventKind.conduct));
      expect(run, isNot(duty));
    });

    test('eventsOn keeps one day, earliest first', () {
      final late = CalendarEvent(
          title: 'IPPT',
          start: DateTime(2023, 7, 5, 14),
          end: DateTime(2023, 7, 5, 16),
          kind: CalendarEventKind.conduct);
      expect(
          eventsOn([late, duty, run], DateTime(2023, 7, 5, 23)), [run, late]);
    });

    test('adapter maps conducts by type and duties as Guard Duty', () async {
      final conducts = _MockConducts();
      final duties = _MockDuties();
      when(() => conducts.watchAll()).thenAnswer((_) => Stream.value(
          Right<Failure, List<Conduct>>([buildConduct(type: 'IPPT')])));
      when(() => duties.watchAll()).thenAnswer(
          (_) => Stream.value(Right<Failure, List<Duty>>([buildDuty()])));
      final events =
          (await CalendarEventAdapter(conducts, duties).watch().first)
              .getOrElse(() => []);
      expect(events.map((e) => (e.title, e.kind)), [
        ('IPPT', CalendarEventKind.conduct),
        ('Guard Duty', CalendarEventKind.guardDuty),
      ]);
      expect(events.last.end, DateTime(2023, 7, 8, 8));
    });
  });

  late _MockSummary watchSummary;
  late _MockEvents watchEvents;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    watchSummary = _MockSummary();
    watchEvents = _MockEvents();
    when(() => watchSummary(any())).thenAnswer(
        (_) => Stream.value(Right<Failure, StrengthSummary>(summary)));
    when(() => watchEvents(any())).thenAnswer(
        (_) => Stream.value(Right<Failure, List<CalendarEvent>>([run, duty])));
  });

  test('EventCalendarProvider selects days and moves months', () async {
    final p = EventCalendarProvider(watchEvents, clock);
    await Future<void>.delayed(Duration.zero);
    expect(p.month, DateTime(2023, 7));
    expect(p.on(p.selected), [run]);
    expect(p.kindsOn(DateTime(2023, 7, 7)), [CalendarEventKind.guardDuty]);
    expect(p.today, DateTime(2023, 7, 5));
    expect(p.selectedEvents, [run]);
    p
      ..shiftMonth(1)
      ..select(DateTime(2023, 8, 2, 13));
    expect(p.month, DateTime(2023, 8));
    expect(p.selected, DateTime(2023, 8, 2));
    p.dispose();
  });

  Future<RouteRecorder> pumpDashboard(WidgetTester tester,
      {ThemeMode mode = ThemeMode.dark}) async {
    final recorder = RouteRecorder();
    await tester.pumpApp(
      Scaffold(
        body: Builder(
            builder: (context) => dashboardTab(context, name: 'Cmd Lim')),
      ),
      mode: mode,
      clock: clock,
      observers: [recorder],
      providers: [
        Provider<WatchStrengthSummary>.value(value: watchSummary),
        Provider<WatchCalendarEvents>.value(value: watchEvents),
      ],
    );
    await tester.pumpAndSettle();
    return recorder;
  }

  testWidgets('welcome, stamp, in-camp count and the four report rows',
      (tester) async {
    await pumpDashboard(tester, mode: themeModes.currentValue!);
    expect(find.text('Welcome, Cmd Lim'), findsOneWidget);
    expect(find.text('As of 5 Jul 2023, 09:30'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('inCampCount'))).data, '2');
    expect(find.text('of 3 soldiers in camp'), findsOneWidget);
    expect(find.text('Officers'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('WOSEs'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
    for (final (title, figure) in [
      ('Total Officers', '1 / 2'),
      ('Total WOSEs', '1 / 1'),
      ('On Status', '1'),
      ('On MA', '0'),
    ]) {
      expect(
          find.descendant(
              of: find.byKey(Key('tile-$title')), matching: find.text(figure)),
          findsOneWidget,
          reason: title);
    }
  }, variant: themeModes);

  testWidgets('the legend counts every state', (tester) async {
    await pumpDashboard(tester);
    for (final (state, label, count) in [
      ('inCamp', 'In camp', '1'),
      ('excuse', 'Excuse', '1'),
      ('leave', 'Leave', '0'),
      ('medical', 'MA', '0'),
      ('out', 'Out', '1'),
    ]) {
      final item = find.byKey(Key('legend-$state'));
      expect(find.descendant(of: item, matching: find.text(label)),
          findsOneWidget);
      expect(find.descendant(of: item, matching: find.text(count)),
          findsOneWidget);
    }
  });

  testWidgets('one tick per soldier, officers then WOSEs', (tester) async {
    await pumpDashboard(tester);
    expect(find.byKey(const ValueKey('tick-0-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('tick-0-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('tick-0-2')), findsNothing);
    expect(find.byKey(const ValueKey('tick-1-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('tick-1-1')), findsNothing);
  });

  testWidgets('a row expands to soldiers that open the profile',
      (tester) async {
    final recorder = await pumpDashboard(tester);
    expect(find.byKey(const Key('soldier-Lt Lee')), findsNothing);
    await tester.tap(find.byKey(const Key('tile-Total Officers')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('soldier-Lt Lee')), findsOneWidget);
    expect(find.byKey(const Key('soldier-Cpt Ong')), findsOneWidget);
    expect(find.byKey(const Key('soldier-Cpl Tan')), findsNothing);
    expect(find.text('In camp'), findsNWidgets(2));
    expect(find.text('Booked out'), findsOneWidget);
    await tester.tap(find.byKey(const Key('soldier-Lt Lee')));
    await tester.pumpAndSettle();
    expect(recorder.names.last, AppRoutes.soldierProfile);
    expect(recorder.lastArguments, 'Lt Lee');
  });

  testWidgets('On Status names the status and a second tap closes the row',
      (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.byKey(const Key('tile-On Status')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('soldier-Cpl Tan')), findsOneWidget);
    expect(find.text('Ex RMJ'), findsOneWidget);
    await tester.tap(find.byKey(const Key('tile-On Status')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('soldier-Cpl Tan')), findsNothing);
  });

  testWidgets('an empty row says there is no personnel', (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.byKey(const Key('tile-On MA')));
    await tester.pumpAndSettle();
    expect(find.text('No personnel'), findsOneWidget);
  });

  group('the open row highlights its ticks', () {
    double opacity(WidgetTester tester, String tick) => tester
        .widget<AnimatedOpacity>(find.ancestor(
            of: find.byKey(ValueKey(tick)),
            matching: find.byType(AnimatedOpacity)))
        .opacity;

    const ticks = ['tick-0-0', 'tick-0-1', 'tick-1-0'];

    testWidgets('officers: the in-camp officer stays, the rest fade',
        (tester) async {
      await pumpDashboard(tester);
      for (final tick in ticks) {
        expect(opacity(tester, tick), 1);
      }
      await tester.tap(find.byKey(const Key('tile-Total Officers')));
      await tester.pumpAndSettle();
      expect(opacity(tester, 'tick-0-0'), 1);
      expect(opacity(tester, 'tick-0-1'), lessThan(1));
      expect(opacity(tester, 'tick-1-0'), lessThan(1));
    });

    testWidgets('on status: the excuse tick stays in any group',
        (tester) async {
      await pumpDashboard(tester);
      await tester.tap(find.byKey(const Key('tile-On Status')));
      await tester.pumpAndSettle();
      expect(opacity(tester, 'tick-1-0'), 1);
      expect(opacity(tester, 'tick-0-0'), lessThan(1));
      expect(opacity(tester, 'tick-0-1'), lessThan(1));
    });

    testWidgets('closing the row clears the highlight', (tester) async {
      await pumpDashboard(tester);
      await tester.tap(find.byKey(const Key('tile-On Status')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile-On Status')));
      await tester.pumpAndSettle();
      for (final tick in ticks) {
        expect(opacity(tester, tick), 1);
      }
    });
  });

  testWidgets('the header holds the greeting and the switch', (tester) async {
    await pumpDashboard(tester);
    for (final text in ['Welcome, Cmd Lim', 'Strength', 'Calendar']) {
      expect(
          find.descendant(
              of: find.byType(GradientHeader), matching: find.text(text)),
          findsOneWidget,
          reason: text);
    }
  });

  testWidgets('the switch moves between strength and calendar', (tester) async {
    await pumpDashboard(tester);
    expect(find.byKey(const Key('inCampCount')), findsOneWidget);
    expect(find.byKey(const Key('nextMonth')), findsNothing);

    await tester.tap(find.byKey(const Key('showCalendar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('inCampCount')), findsNothing);
    expect(find.byKey(const Key('nextMonth')), findsOneWidget);
    expect(find.text('Welcome, Cmd Lim'), findsOneWidget);

    await tester.tap(find.byKey(const Key('showStrength')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('inCampCount')), findsOneWidget);
    expect(find.byKey(const Key('nextMonth')), findsNothing);
  });

  testWidgets('with the calendar shown, days list their events',
      (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.byKey(const Key('showCalendar')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('day-7 Jul 2023')));
    await tester.tap(find.byKey(const Key('day-7 Jul 2023')));
    await tester.pumpAndSettle();
    expect(find.text('July 7, 2023'), findsOneWidget);
    expect(find.text('1 event'), findsOneWidget);
    expect(find.text('8:00 AM - 8:00 AM (Next day)'), findsOneWidget);
    expect(find.text('Guard Duty'), findsOneWidget);
    expect(find.byKey(Key('event-Guard Duty-${duty.start.toIso8601String()}')),
        findsOneWidget);
  });

  testWidgets('a day without events says so and shows no count',
      (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.byKey(const Key('showCalendar')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('day-12 Jul 2023')));
    await tester.tap(find.byKey(const Key('day-12 Jul 2023')));
    await tester.pumpAndSettle();
    expect(find.text('July 12, 2023'), findsOneWidget);
    expect(find.text('No events'), findsOneWidget);
    expect(find.text('0 events'), findsNothing);
  });

  group('the month card', () {
    Future<void> openCalendar(WidgetTester tester,
        {ThemeMode mode = ThemeMode.dark}) async {
      await pumpDashboard(tester, mode: mode);
      await tester.tap(find.byKey(const Key('showCalendar')));
      await tester.pumpAndSettle();
    }

    testWidgets('has no seasonal banner', (tester) async {
      await openCalendar(tester);
      expect(find.byKey(const Key('monthBanner')), findsNothing);
      expect(find.byType(Image), findsNothing);
      expect(find.text('July 2023'), findsOneWidget);
    });

    testWidgets('month navigation moves and returns', (tester) async {
      await openCalendar(tester);
      await tester.tap(find.byKey(const Key('nextMonth')));
      await tester.pumpAndSettle();
      expect(find.text('August 2023'), findsOneWidget);
      expect(find.byKey(const Key('day-31 Aug 2023')), findsOneWidget);
      await tester.tap(find.byKey(const Key('prevMonth')));
      await tester.tap(find.byKey(const Key('prevMonth')));
      await tester.pumpAndSettle();
      expect(find.text('June 2023'), findsOneWidget);
      expect(find.byKey(const Key('day-30 Jun 2023')), findsOneWidget);
    });

    testWidgets('neighbouring days are shown but cannot be picked',
        (tester) async {
      await openCalendar(tester);
      expect(find.text('26'), findsWidgets);
      expect(find.byKey(const Key('day-26 Jun 2023')), findsNothing);
      expect(find.byKey(const Key('day-1 Jul 2023')), findsOneWidget);
    });

    testWidgets('dots: amber for a conduct, pink for a duty', (tester) async {
      await openCalendar(tester);
      Color? dotColor(String day, String kind) {
        final dot = find.byKey(Key('dot-$day-$kind'));
        if (dot.evaluate().isEmpty) return null;
        return (tester
                .widget<DecoratedBox>(find.descendant(
                    of: dot, matching: find.byType(DecoratedBox)))
                .decoration as BoxDecoration)
            .color;
      }

      expect(dotColor('5 Jul 2023', 'conduct'), AppColors.warning);
      expect(dotColor('5 Jul 2023', 'guardDuty'), isNull);
      expect(dotColor('7 Jul 2023', 'guardDuty'), AppColors.calendarDuty);
      expect(dotColor('7 Jul 2023', 'conduct'), isNull);
      expect(find.byKey(const Key('dot-12 Jul 2023-conduct')), findsNothing);
    });

    testWidgets('the legend names both kinds', (tester) async {
      await openCalendar(tester);
      expect(
          find.descendant(
              of: find.byKey(const Key('legend-conduct')),
              matching: find.text('Conduct')),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const Key('legend-guardDuty')),
              matching: find.text('Guard duty')),
          findsOneWidget);
    });

    testWidgets('the picked day is filled and today is outlined',
        (tester) async {
      await openCalendar(tester);
      Material cell(String day) => tester.widget<Material>(find
          .ancestor(
              of: find.byKey(Key('day-$day')), matching: find.byType(Material))
          .first);
      final selected = cell('5 Jul 2023');
      expect(selected.color, AppColors.brandIndigo);
      expect(cell('6 Jul 2023').color, Colors.transparent);

      await tester.ensureVisible(find.byKey(const Key('day-7 Jul 2023')));
      await tester.tap(find.byKey(const Key('day-7 Jul 2023')));
      await tester.pumpAndSettle();
      expect(cell('7 Jul 2023').color, AppColors.brandIndigo);
      final today = cell('5 Jul 2023');
      expect(today.color, Colors.transparent);
      expect(
          (today.shape as RoundedRectangleBorder).side.width, greaterThan(0));
    });

    testWidgets('lays out in light mode too', (tester) async {
      await openCalendar(tester, mode: ThemeMode.light);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('day-5 Jul 2023')), findsOneWidget);
    });
  });

  testWidgets('a failed strength stream shows the error', (tester) async {
    when(() => watchSummary(any())).thenAnswer((_) => Stream.value(
        const Left<Failure, StrengthSummary>(ServerFailure('Strength down'))));
    await pumpDashboard(tester);
    expect(find.widgetWithText(ErrorView, 'Strength down'), findsOneWidget);
  });

  testWidgets('a failed events stream shows the error under the calendar',
      (tester) async {
    when(() => watchEvents(any())).thenAnswer((_) => Stream.value(
        const Left<Failure, List<CalendarEvent>>(
            ServerFailure('Events down'))));
    await pumpDashboard(tester);
    await tester.tap(find.byKey(const Key('showCalendar')));
    await tester.pumpAndSettle();
    final error = find.widgetWithText(ErrorView, 'Events down');
    await tester.ensureVisible(error);
    expect(error, findsOneWidget);
    expect(find.text('No events'), findsNothing);
  });
}

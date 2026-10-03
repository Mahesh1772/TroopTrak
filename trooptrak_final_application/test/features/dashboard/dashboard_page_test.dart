import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/di/calendar_event_adapter.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/core/widgets/soldier_card.dart';
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
      officers: [lt, cpt], woses: [cpl], onStatus: [cpl], onMa: const []);
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
    expect(p.kindsOn(DateTime(2023, 7, 7)), {CalendarEventKind.guardDuty});
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

  testWidgets('welcome, stamp, chart count and the four tiles', (tester) async {
    await pumpDashboard(tester, mode: themeModes.currentValue!);
    expect(find.text('Welcome,\nCmd Lim! 👋'), findsOneWidget);
    expect(find.text('As of July 5, 2023 09:30'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('inCampCount'))).data, '2');
    expect(find.text('of 3 soldiers'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('0 / 3'), findsOneWidget);
  }, variant: themeModes);

  testWidgets('a tile expands to soldier cards that open the profile',
      (tester) async {
    final recorder = await pumpDashboard(tester);
    await tester.tap(find.byKey(const Key('tile-Total Officers')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(SoldierCard, 'Lt Lee'), findsOneWidget);
    expect(find.widgetWithText(SoldierCard, 'Cpt Ong'), findsNothing);
    await tester.tap(find.widgetWithText(SoldierCard, 'Lt Lee'));
    await tester.pumpAndSettle();
    expect(recorder.names.last, AppRoutes.soldierProfile);
    expect(recorder.lastArguments, 'Lt Lee');
  });

  testWidgets('Show Calendar flips to the calendar; days list their events',
      (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.byKey(const Key('showCalendar')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('day-7 Jul 2023')));
    await tester.tap(find.byKey(const Key('day-7 Jul 2023')));
    await tester.pumpAndSettle();
    expect(find.text('July 7, 2023'), findsOneWidget);
    expect(find.text('8:00 AM - 8:00 AM'), findsOneWidget);
    expect(find.text('Guard Duty'), findsOneWidget);
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

  testWidgets('the month header carries the source month banner',
      (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.byKey(const Key('showCalendar')));
    await tester.pumpAndSettle();
    Image banner() =>
        tester.widget<Image>(find.byKey(const Key('monthBanner')));
    expect((banner().image as AssetImage).assetName,
        'lib/assets/calendar-images/July.png');
    expect(find.text('July 2023'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nextMonth')));
    await tester.pumpAndSettle();
    expect((banner().image as AssetImage).assetName,
        'lib/assets/calendar-images/August.png');
  });
}

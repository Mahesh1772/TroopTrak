import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/conducts/domain/entities/conduct.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/conduct_usecases.dart';
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
  final ippt =
      buildConduct(id: 'ippt', name: 'IPPT', type: 'IPPT', participants: ['A']);
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
    when(() => soldiers(any())).thenAnswer((_) => Stream.value(
        Right<Failure, List<Soldier>>(
            [for (var i = 0; i < 10; i++) buildSoldier(name: 'S$i')])));
  });

  ConductTrackerProvider provider() => ConductTrackerProvider(
      watchOnDay: onDay, watchSoldiers: soldiers, clock: clock);

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

    test('bars count participants; max is unit strength (K20)', () async {
      final p = provider();
      await Future<void>.delayed(Duration.zero);
      expect(p.bars, [
        (label: 'Morning Run', participants: 3),
        (label: 'IPPT', participants: 1),
      ]);
      expect(p.chartMax, 10);
      p.dispose();
    });

    test('max never drops below the tallest bar', () async {
      when(() => soldiers(any())).thenAnswer(
          (_) => Stream.value(const Right<Failure, List<Soldier>>([])));
      final p = provider();
      await Future<void>.delayed(Duration.zero);
      expect(p.chartMax, 3);
      p.dispose();
    });

    test('range runs from 2022 to a year after today', () {
      final p = provider();
      expect(p.firstDay, DateTime(2022));
      expect(p.lastDay, DateTime(2024, 7, 5));
      p.dispose();
    });
  });

  Future<RouteRecorder> pumpTracker(WidgetTester tester,
      {bool canManage = true, ThemeMode mode = ThemeMode.dark}) async {
    final recorder = RouteRecorder();
    await tester.pumpApp(
      Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => provider(),
          child: ConductTrackerPage(canManage: canManage),
        ),
      ),
      mode: mode,
      clock: clock,
      observers: [recorder],
    );
    await tester.pumpAndSettle();
    return recorder;
  }

  group('ConductTrackerPage', () {
    testWidgets('shows the chart and numbered tiles for the day',
        (tester) async {
      await pumpTracker(tester, mode: themeModes.currentValue!);
      expect(find.text('July 5, 2023'), findsOneWidget);
      expect(find.text('Participation Strength'), findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.byKey(const Key('conduct-run')), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    }, variant: themeModes);

    testWidgets('tapping another day on the strip updates the list',
        (tester) async {
      await pumpTracker(tester);
      await tester.tap(find.byKey(const ValueKey('date-strip-6 Jul 2023')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('conduct-rm')), findsOneWidget);
      expect(find.byKey(const Key('conduct-run')), findsNothing);
    });

    testWidgets('a day without conducts shows the empty image and text',
        (tester) async {
      await pumpTracker(tester);
      await tester.tap(find.byKey(const ValueKey('date-strip-7 Jul 2023')));
      await tester.pumpAndSettle();
      expect(find.text('NO CONDUCTS FOR TODAY!'), findsOneWidget);
      expect(
          find.byWidgetPredicate((w) =>
              w is Image &&
              (w.image as AssetImage).assetName ==
                  'lib/assets/noConductspng.png'),
          findsOneWidget);
    });

    testWidgets('tiles open the conduct details by id', (tester) async {
      final recorder = await pumpTracker(tester);
      await tester.tap(find.byKey(const Key('conduct-ippt')));
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
}

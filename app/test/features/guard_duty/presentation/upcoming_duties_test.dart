import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/core/widgets/soldier_card.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/entities/duty.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/usecases/duty_usecases.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/providers/upcoming_duties_provider.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/widgets/upcoming_duties_tab.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';
import '../../../helpers/pump_app.dart';

class _MockWatch extends Mock implements WatchDuties {}

class _MockDelete extends Mock implements DeleteDuty {}

void main() {
  final clock = FixedClock(DateTime(2023, 7, 5, 9));
  final yesterday = buildDuty(id: 'y', start: DateTime(2023, 7, 4, 8));
  final today = buildDuty(
      id: 't',
      start: DateTime(2023, 7, 5, 8),
      participants: {'Tan Ah Kow': 'CPL', 'Lee Wei': '2LT'});
  final later = buildDuty(id: 'l', start: DateTime(2023, 7, 9, 8));
  final soon = buildDuty(id: 's', start: DateTime(2023, 7, 6, 8));
  late _MockWatch watch;
  late _MockDelete delete;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(buildDuty());
  });

  setUp(() {
    watch = _MockWatch();
    delete = _MockDelete();
    when(() => watch(any())).thenAnswer((_) => Stream.value(
        Right<Failure, List<Duty>>([later, today, yesterday, soon])));
    when(() => delete(any())).thenAnswer((_) async => const Right(unit));
  });

  UpcomingDutiesProvider provider() =>
      UpcomingDutiesProvider(watch: watch, delete: delete, clock: clock);

  group('UpcomingDutiesProvider (R14a)', () {
    test('today = 0 days from the selection; upcoming = 1+, by date', () async {
      final p = provider();
      await Future<void>.delayed(Duration.zero);
      expect(p.onSelectedDay, [today]);
      expect(p.upcoming, [soon, later]);

      p.select(DateTime(2023, 7, 6, 23));
      expect(p.onSelectedDay, [soon]);
      expect(p.upcoming, [later]);
      p.dispose();
    });

    test('participation is tracked only for a named soldier', () {
      final commander = provider();
      expect(commander.isParticipating(today), isNull);
      commander.dispose();

      final soldier = UpcomingDutiesProvider(
          watch: watch, delete: delete, clock: clock, participant: 'Lee Wei');
      expect(soldier.isParticipating(today), isTrue);
      expect(soldier.isParticipating(later), isFalse);
      soldier.dispose();
    });

    test('delete reports failures', () async {
      final p = provider();
      expect(await p.delete(today), isNull);
      when(() => delete(any()))
          .thenAnswer((_) async => const Left(ServerFailure('down')));
      expect(await p.delete(today), 'down');
      p.dispose();
    });
  });

  Future<RouteRecorder> pumpTab(WidgetTester tester,
      {bool canManage = true, ThemeMode mode = ThemeMode.dark}) async {
    final recorder = RouteRecorder();
    await tester.pumpApp(
      Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => provider(),
          child: UpcomingDutiesTab(canManage: canManage),
        ),
      ),
      mode: mode,
      clock: clock,
      observers: [recorder],
    );
    await tester.pumpAndSettle();
    return recorder;
  }

  Future<void> expand(WidgetTester tester, String id) async {
    await tester.tap(find.byKey(Key('duty-$id')));
    await tester.pumpAndSettle();
  }

  group('UpcomingDutiesTab', () {
    testWidgets('sections, today label and duty tiles', (tester) async {
      await pumpTab(tester, mode: themeModes.currentValue!);
      expect(find.text("Today's Duties"), findsOneWidget);
      expect(find.text('July 5, 2023'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byKey(const Key('duty-t')), findsOneWidget);
      expect(find.byKey(const Key('duty-s')), findsOneWidget);
      expect(find.byKey(const Key('duty-y')), findsNothing);
      expect(find.text('1.5'), findsWidgets);
    }, variant: themeModes);

    testWidgets('expanding shows the participant cards', (tester) async {
      await pumpTab(tester);
      await expand(tester, 't');
      expect(find.byType(SoldierCard), findsNWidgets(2));
      expect(find.text('Lee Wei'), findsOneWidget);
    });

    testWidgets('delete asks, then deletes once', (tester) async {
      await pumpTab(tester);
      await expand(tester, 't');
      final button = find.byKey(const Key('deleteDuty-t'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Every participant loses 1.5 points.'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      verifyNever(() => delete(any()));

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      verify(() => delete(today)).called(1);
      expect(find.text('Duty deleted'), findsOneWidget);
    });

    testWidgets('a failed delete shows the error snackbar', (tester) async {
      when(() => delete(any()))
          .thenAnswer((_) async => const Left(ServerFailure('No network')));
      await pumpTab(tester);
      await expand(tester, 't');
      final button = find.byKey(const Key('deleteDuty-t'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('No network'), findsOneWidget);
      expect(find.text('Duty deleted'), findsNothing);
    });

    testWidgets('a failed duty stream shows the error', (tester) async {
      when(() => watch(any())).thenAnswer((_) => Stream.value(
          const Left<Failure, List<Duty>>(ServerFailure('Duties down'))));
      await pumpTab(tester);
      expect(find.widgetWithText(ErrorView, 'Duties down'), findsOneWidget);
      expect(find.text("Today's Duties"), findsNothing);
    });

    testWidgets('edit opens the duty form with the duty', (tester) async {
      final recorder = await pumpTab(tester);
      await expand(tester, 't');
      final button = find.byKey(const Key('editDuty-t'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.editDuty);
      expect(recorder.lastArguments, today);
    });

    testWidgets('empty sections show the source messages', (tester) async {
      when(() => watch(any())).thenAnswer(
          (_) => Stream.value(Right<Failure, List<Duty>>([yesterday])));
      await pumpTab(tester, canManage: false);
      expect(find.text('NO DUTIES FOR TODAY!'), findsOneWidget);
      expect(find.text('NO UPCOMING DUTIES!'), findsOneWidget);
    });

    testWidgets('read-only tiles have no edit or delete', (tester) async {
      await pumpTab(tester, canManage: false);
      await expand(tester, 't');
      expect(find.byKey(const Key('editDuty-t')), findsNothing);
      expect(find.byKey(const Key('deleteDuty-t')), findsNothing);
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/entities/duty.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/usecases/duty_usecases.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/guard_duty_routes.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/usecases/soldier_usecases.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';
import '../../../helpers/pump_app.dart';

class _MockSoldiers extends Mock implements WatchSoldiers {}

class _MockDuties extends Mock implements WatchDuties {}

class _MockDelete extends Mock implements DeleteDuty {}

void main() {
  late _MockSoldiers soldiers;
  late _MockDuties duties;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    soldiers = _MockSoldiers();
    duties = _MockDuties();
    when(() => soldiers(any())).thenAnswer((_) =>
        Stream.value(Right<Failure, List<Soldier>>([buildSoldier(points: 3)])));
    when(() => duties(any())).thenAnswer((_) => Stream.value(
        Right<Failure, List<Duty>>(
            [buildDuty(start: DateTime(2023, 7, 5, 8))])));
  });

  Future<RouteRecorder> pumpPage(WidgetTester tester,
      {bool canManage = true, ThemeMode mode = ThemeMode.dark}) async {
    final recorder = RouteRecorder();
    await tester.pumpApp(
      Scaffold(
        body: Builder(
            builder: (context) => guardDutyTab(context, canManage: canManage)),
      ),
      mode: mode,
      clock: FixedClock(DateTime(2023, 7, 5, 9)),
      observers: [recorder],
      providers: [
        Provider<WatchSoldiers>.value(value: soldiers),
        Provider<WatchDuties>.value(value: duties),
        Provider<DeleteDuty>.value(value: _MockDelete()),
      ],
    );
    await tester.pumpAndSettle();
    return recorder;
  }

  testWidgets('two tabs: leaderboard first, upcoming duties second',
      (tester) async {
    await pumpPage(tester, mode: themeModes.currentValue!);
    expect(find.text('POINTS LEADERBOARD'), findsOneWidget);
    expect(find.text('UPCOMING DUTIES'), findsOneWidget);
    expect(find.text('Points Leaderboard'), findsOneWidget);
    await tester.tap(find.text('UPCOMING DUTIES'));
    await tester.pumpAndSettle();
    expect(find.text("Today's Duties"), findsOneWidget);
    expect(find.byKey(const Key('duty-d1')), findsOneWidget);
  }, variant: themeModes);

  testWidgets('commanders get the add-duty button', (tester) async {
    final recorder = await pumpPage(tester);
    await tester.tap(find.byKey(const Key('addDuty')));
    await tester.pumpAndSettle();
    expect(recorder.names.last, AppRoutes.addDuty);
  });

  testWidgets('read-only page has no add-duty button', (tester) async {
    await pumpPage(tester, canManage: false);
    expect(find.byKey(const Key('addDuty')), findsNothing);
  });
}

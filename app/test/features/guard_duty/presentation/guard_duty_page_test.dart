import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/theme/app_layout.dart';
import 'package:trooptrak_final_application/core/theme/app_radii.dart';
import 'package:trooptrak_final_application/core/theme/theme_context.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/core/widgets/icon_tab.dart';
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
    when(() => duties(any()))
        .thenAnswer((_) => Stream.value(Right<Failure, List<Duty>>([
              buildDuty(start: DateTime(2023, 7, 5, 8)),
              buildDuty(
                  id: 'd2',
                  start: DateTime(2023, 7, 8, 8),
                  participants: {'Lim Bah': 'PTE'}),
            ])));
  });

  Future<RouteRecorder> pumpPage(WidgetTester tester,
      {bool canManage = true, ThemeMode mode = ThemeMode.dark}) async {
    final recorder = RouteRecorder();
    await tester.pumpApp(
      Scaffold(
        body: Builder(
            builder: (context) => canManage
                ? guardDutyTab(context)
                : soldierGuardDutyTab(context, 'Tan Ah Kow')),
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

  testWidgets('two tabs: LEADERBOARD first, UPCOMING second', (tester) async {
    await pumpPage(tester, mode: themeModes.currentValue!);
    expect(find.text('LEADERBOARD'), findsOneWidget);
    expect(find.text('UPCOMING'), findsOneWidget);
    expect(find.text('POINTS LEADERBOARD'), findsNothing);
    expect(find.text('UPCOMING DUTIES'), findsNothing);
    expect(find.text('Points Leaderboard'), findsOneWidget);
    await tester.tap(find.text('UPCOMING'));
    await tester.pumpAndSettle();
    expect(find.text("Today's Duties"), findsOneWidget);
    expect(find.byKey(const Key('duty-d1')), findsOneWidget);
  }, variant: themeModes);

  testWidgets('the tab bar is two icon tabs on one line, 50 high',
      (tester) async {
    await pumpPage(tester, mode: themeModes.currentValue!);
    final tabs = tester.widgetList<IconTab>(find.byType(IconTab)).toList();
    expect([for (final tab in tabs) tab.label], ['LEADERBOARD', 'UPCOMING']);
    expect([for (final tab in tabs) tab.icon],
        [Icons.leaderboard_rounded, Icons.more_time_rounded]);
    expect(tester.getSize(find.byType(TabBar)).height, 50);
    final tabWidth = tester.getSize(find.byType(TabBar)).width / 2;
    for (final label in ['LEADERBOARD', 'UPCOMING']) {
      expect(tester.getSize(find.text(label)).width, lessThan(tabWidth));
    }
  }, variant: themeModes);

  testWidgets('the tab bar is under the page, with the bodies below it',
      (tester) async {
    await pumpPage(tester);
    final bar = tester.getRect(find.byType(TabBar));
    expect(tester.getRect(find.byType(TabBarView)).top, bar.bottom);
  });

  testWidgets('the add-duty button is a themed 20 px rounded square',
      (tester) async {
    await pumpPage(tester, mode: themeModes.currentValue!);
    final fab = find.byKey(const Key('addDuty'));
    final material = tester.widget<Material>(
        find.descendant(of: fab, matching: find.byType(Material)).first);
    expect(
        material.shape,
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.xl)));
    final size = tester.getSize(fab);
    expect([size.width, size.height], [AppLayout.fabSize, AppLayout.fabSize]);
    expect(tester.widget<FloatingActionButton>(fab).heroTag, isNull);
  }, variant: themeModes);

  testWidgets('commanders get the add-duty button', (tester) async {
    final recorder = await pumpPage(tester);
    await tester.tap(find.byKey(const Key('addDuty')));
    await tester.pumpAndSettle();
    expect(recorder.names.last, AppRoutes.addDuty);
  });

  testWidgets('commanders get edit and delete but no participation marks',
      (tester) async {
    await pumpPage(tester);
    expect(find.text('Guard Duty'), findsNothing);
    await tester.tap(find.text('UPCOMING'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('onDuty-d1')), findsNothing);
    await tester.tap(find.byKey(const Key('duty-d1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editDuty-d1')), findsOneWidget);
    expect(find.byKey(const Key('deleteDuty-d1')), findsOneWidget);
  });

  group('soldier guard duty tab', () {
    testWidgets('has a title, both tabs and no add-duty button',
        (tester) async {
      await pumpPage(tester, canManage: false, mode: themeModes.currentValue!);
      expect(find.text('Guard Duty'), findsOneWidget);
      expect(find.byKey(const Key('addDuty')), findsNothing);
      expect(find.text('LEADERBOARD'), findsOneWidget);
      expect(find.text('UPCOMING'), findsOneWidget);
      expect(find.text('Points Leaderboard'), findsOneWidget);
    }, variant: themeModes);

    testWidgets('the title is the 24 w600 page title in the theme colour',
        (tester) async {
      await pumpPage(tester, canManage: false, mode: themeModes.currentValue!);
      final title = tester.widget<Text>(find.text('Guard Duty'));
      final colors = tester.element(find.byType(TabBar)).colors;
      expect(title.style!.fontSize, 24);
      expect(title.style!.fontWeight, FontWeight.w600);
      expect(title.style!.color, colors.onSurface);
      expect(tester.getSize(find.text('Guard Duty')).height,
          lessThan(AppLayout.appBarHeight));
      expect(tester.getRect(find.text('Guard Duty')).bottom,
          lessThan(tester.getRect(find.byType(TabBar)).top));
    }, variant: themeModes);

    testWidgets('duties are read-only and mark the soldier\'s own',
        (tester) async {
      await pumpPage(tester, canManage: false);
      await tester.tap(find.text('UPCOMING'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('onDuty-d1')), findsOneWidget);
      expect(find.byKey(const Key('offDuty-d2')), findsOneWidget);

      await tester.tap(find.byKey(const Key('duty-d1')));
      await tester.pumpAndSettle();
      expect(find.text('Participants'), findsOneWidget);
      expect(find.byKey(const Key('editDuty-d1')), findsNothing);
      expect(find.byKey(const Key('deleteDuty-d1')), findsNothing);
    });
  });
}

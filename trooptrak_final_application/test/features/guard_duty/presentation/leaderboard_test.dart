import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/providers/leaderboard_provider.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/widgets/leaderboard_tab.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/usecases/soldier_usecases.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/pump_app.dart';

class _MockWatch extends Mock implements WatchSoldiers {}

void main() {
  final tan = buildSoldier(name: 'Tan Ah Kow', rank: 'CPL', points: 2);
  final lee = buildSoldier(name: 'Lee Wei', rank: '2LT', points: 5.5);
  final ali = buildSoldier(name: 'Ali Bin', rank: 'PTE', points: 1);
  late _MockWatch watch;

  setUpAll(() => registerFallbackValue(const NoParams()));
  setUp(() {
    watch = _MockWatch();
    when(() => watch(any())).thenAnswer(
        (_) => Stream.value(Right<Failure, List<Soldier>>([tan, lee, ali])));
  });

  Future<LeaderboardProvider> loaded() async {
    final p = LeaderboardProvider(watch);
    await Future<void>.delayed(Duration.zero);
    return p;
  }

  group('LeaderboardProvider', () {
    test('defaults to points, highest first', () async {
      final p = await loaded();
      expect(p.rows, [lee, tan, ali]);
      p.dispose();
    });

    test('tapping the same column flips it', () async {
      final p = await loaded()
        ..sortBy(LeaderboardColumn.points);
      expect(p.rows, [ali, tan, lee]);
      p.dispose();
    });

    test('name sorts A to Z first; rank sorts most senior first', () async {
      final p = await loaded()
        ..sortBy(LeaderboardColumn.name);
      expect(p.rows, [ali, lee, tan]);
      p.sortBy(LeaderboardColumn.rank);
      expect(p.rows, [lee, tan, ali]);
      p.sortBy(LeaderboardColumn.rank);
      expect(p.rows, [ali, tan, lee]);
      p.dispose();
    });

    test('search filters by name, case-insensitively', () async {
      final p = await loaded()
        ..search('TAN');
      expect(p.rows, [tan]);
      p.dispose();
    });
  });

  group('LeaderboardTab', () {
    Future<void> pumpTab(WidgetTester tester,
            {ThemeMode mode = ThemeMode.dark}) =>
        tester.pumpApp(
          Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => LeaderboardProvider(watch),
              child: const LeaderboardTab(),
            ),
          ),
          mode: mode,
        );

    List<String> names(WidgetTester tester) => tester
        .widget<DataTable>(find.byKey(const Key('leaderboard')))
        .rows
        .map((r) => ((r.cells[1].child as Text).data!))
        .toList();

    testWidgets('renders rank, name and points per row', (tester) async {
      await pumpTab(tester, mode: themeModes.currentValue!);
      await tester.pumpAndSettle();
      expect(find.text('Points Leaderboard'), findsOneWidget);
      expect(names(tester), ['Lee Wei', 'Tan Ah Kow', 'Ali Bin']);
      expect(find.text('5.5'), findsOneWidget);
    }, variant: themeModes);

    testWidgets('tapping a header sorts by that column', (tester) async {
      await pumpTab(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sort-name')));
      await tester.pumpAndSettle();
      expect(names(tester), ['Ali Bin', 'Lee Wei', 'Tan Ah Kow']);
    });

    testWidgets('search narrows the table', (tester) async {
      await pumpTab(tester);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'lee');
      await tester.pumpAndSettle();
      expect(names(tester), ['Lee Wei']);
    });
  });
}

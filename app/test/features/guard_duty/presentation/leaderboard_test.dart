import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/theme/app_layout.dart';
import 'package:trooptrak_final_application/core/theme/theme_context.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/core/widgets/rank_plate.dart';
import 'package:trooptrak_final_application/core/widgets/state_tone.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/providers/leaderboard_provider.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/widgets/leaderboard_row.dart';
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

  Future<LeaderboardProvider> loaded({String? selfName}) async {
    final p = LeaderboardProvider(watch, selfName: selfName);
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

    test('bars are scaled to the top score, even while searching', () async {
      final p = await loaded()
        ..search('tan');
      expect(p.barFraction(lee), 1);
      expect(p.barFraction(tan), 2 / 5.5);
      expect(p.barFraction(ali), 1 / 5.5);
      p.dispose();
    });

    test('bars are empty, not NaN, when nobody has points', () async {
      when(() => watch(any())).thenAnswer((_) => Stream.value(
          Right<Failure, List<Soldier>>([buildSoldier(points: 0)])));
      final p = await loaded();
      expect(p.barFraction(p.rows!.single), 0);
      p.dispose();
    });

    test('only the signed-in soldier is self', () async {
      final soldier = await loaded(selfName: 'Lee Wei');
      final commander = await loaded();
      expect([
        for (final s in [tan, lee, ali]) soldier.isSelf(s)
      ], [
        false,
        true,
        false
      ]);
      expect([
        for (final s in [tan, lee, ali]) commander.isSelf(s)
      ], [
        false,
        false,
        false
      ]);
      soldier.dispose();
      commander.dispose();
    });
  });

  group('LeaderboardTab', () {
    Future<void> pumpTab(
      WidgetTester tester, {
      ThemeMode mode = ThemeMode.dark,
      String? selfName,
    }) =>
        tester.pumpApp(
          Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => LeaderboardProvider(watch, selfName: selfName),
              child: const LeaderboardTab(),
            ),
          ),
          mode: mode,
        );

    List<String> names(WidgetTester tester) => [
          for (final row
              in tester.widgetList<LeaderboardRow>(find.byType(LeaderboardRow)))
            row.soldier.name,
        ];

    Finder inRow(String id, Finder matching) => find.descendant(
        of: find.byKey(ValueKey('row-$id')), matching: matching);

    Finder inKey(String key, Finder matching) =>
        find.descendant(of: find.byKey(Key(key)), matching: matching);

    testWidgets('renders rank, name and points per row', (tester) async {
      await pumpTab(tester, mode: themeModes.currentValue!);
      await tester.pumpAndSettle();
      expect(find.text('Points Leaderboard'), findsOneWidget);
      expect(find.byKey(const Key('leaderboard')), findsOneWidget);
      expect(names(tester), ['Lee Wei', 'Tan Ah Kow', 'Ali Bin']);
      expect(find.text('5.5'), findsOneWidget);
      expect(find.text('2.0'), findsOneWidget);
      expect(find.text('1.0'), findsOneWidget);
      expect(find.byType(RankPlate), findsNWidgets(3));
      for (final soldier in [tan, lee, ali]) {
        expect(inRow(soldier.id, find.text(soldier.name)), findsOneWidget);
        expect(inRow(soldier.id, find.text(soldier.rank)), findsOneWidget);
      }
    }, variant: themeModes);

    testWidgets('the header shows RANK, NAME and POINTS in the theme colours',
        (tester) async {
      await pumpTab(tester, mode: themeModes.currentValue!);
      await tester.pumpAndSettle();
      final palette =
          tester.element(find.byKey(const Key('leaderboard'))).palette;
      for (final (key, label, color) in [
        ('sort-rank', 'RANK', palette.secondaryText),
        ('sort-name', 'NAME', palette.secondaryText),
        ('sort-points', 'POINTS', palette.onCard),
      ]) {
        final title = inKey(key, find.text(label));
        expect(title, findsOneWidget);
        expect(tester.widget<Text>(title).style!.color, color);
      }
    }, variant: themeModes);

    testWidgets('the sorted column shows its direction and flips on a tap',
        (tester) async {
      await pumpTab(tester);
      await tester.pumpAndSettle();
      expect(inKey('sort-points', find.byIcon(Icons.arrow_downward_rounded)),
          findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);

      await tester.tap(find.byKey(const Key('sort-points')));
      await tester.pumpAndSettle();
      expect(names(tester), ['Ali Bin', 'Tan Ah Kow', 'Lee Wei']);
      expect(inKey('sort-points', find.byIcon(Icons.arrow_upward_rounded)),
          findsOneWidget);

      await tester.tap(find.byKey(const Key('sort-rank')));
      await tester.pumpAndSettle();
      expect(names(tester), ['Lee Wei', 'Tan Ah Kow', 'Ali Bin']);
      expect(inKey('sort-rank', find.byIcon(Icons.arrow_upward_rounded)),
          findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
    });

    testWidgets('tapping a header sorts by that column', (tester) async {
      await pumpTab(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sort-name')));
      await tester.pumpAndSettle();
      expect(names(tester), ['Ali Bin', 'Lee Wei', 'Tan Ah Kow']);
    });

    testWidgets('each row has a bar scaled to the top score', (tester) async {
      await pumpTab(tester, mode: themeModes.currentValue!);
      await tester.pumpAndSettle();
      double factor(String id) => tester
          .widget<FractionallySizedBox>(find.byKey(Key('bar-$id')))
          .widthFactor!;
      expect(factor('Lee Wei'), 1);
      expect(factor('Tan Ah Kow'), 2 / 5.5);
      expect(factor('Ali Bin'), 1 / 5.5);
      final top = tester.getSize(find.byKey(const Key('bar-Lee Wei')));
      expect(top.height, AppLayout.leaderboardBar);
      expect(tester.getSize(find.byKey(const Key('bar-Ali Bin'))).width,
          closeTo(top.width / 5.5, 0.01));
    }, variant: themeModes);

    testWidgets('a soldier sees their own row highlighted and marked You',
        (tester) async {
      await pumpTab(tester,
          mode: themeModes.currentValue!, selfName: 'Tan Ah Kow');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('self-Tan Ah Kow')), findsOneWidget);
      expect(find.byKey(const Key('self-Lee Wei')), findsNothing);
      expect(find.byKey(const Key('self-Ali Bin')), findsNothing);
      expect(find.text('CPL · You'), findsOneWidget);
      expect(find.textContaining('You'), findsOneWidget);
      final fill = tester
          .widget<ColoredBox>(find.byKey(const Key('self-Tan Ah Kow')))
          .color;
      final palette = tester.element(find.byType(LeaderboardRow).first).palette;
      expect(fill, StateTone.accent.tint(palette));
    }, variant: themeModes);

    testWidgets('a commander has no highlighted row', (tester) async {
      await pumpTab(tester);
      await tester.pumpAndSettle();
      expect(find.textContaining('You'), findsNothing);
      for (final soldier in [tan, lee, ali]) {
        expect(find.byKey(Key('self-${soldier.id}')), findsNothing);
      }
    });

    testWidgets('search narrows the list', (tester) async {
      await pumpTab(tester);
      await tester.pumpAndSettle();
      expect(find.text('Search Name'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('leaderboardSearch')), 'lee');
      await tester.pumpAndSettle();
      expect(names(tester), ['Lee Wei']);
    });

    testWidgets('a failed soldier stream shows the error', (tester) async {
      when(() => watch(any())).thenAnswer((_) => Stream.value(
          const Left<Failure, List<Soldier>>(ServerFailure('Points down'))));
      await pumpTab(tester);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ErrorView, 'Points down'), findsOneWidget);
      expect(find.byKey(const Key('leaderboard')), findsNothing);
    });
  });
}

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
import 'package:trooptrak_final_application/core/widgets/rank_chip.dart';
import 'package:trooptrak_final_application/core/widgets/rank_plate.dart';
import 'package:trooptrak_final_application/core/widgets/state_chip.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/watch_parade_roster.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/services/roster_filter.dart';
import 'package:trooptrak_final_application/features/nominal_roll/presentation/pages/nominal_roll_page.dart';
import 'package:trooptrak_final_application/features/nominal_roll/presentation/providers/nominal_roll_provider.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_roster.dart';

import '../../helpers/builders.dart';
import '../../helpers/pump_app.dart';

class _MockWatch extends Mock implements WatchParadeRoster {}

class _MockBook extends Mock implements BookInOut {}

void main() {
  final today = DateTime(2023, 7, 5, 9);
  final tan = buildSoldier(name: 'Tan Ah Kow', rank: 'CPL');
  final lee = buildSoldier(
      name: 'Lee Wei',
      rank: '2LT',
      appointment: 'Platoon Commander',
      isInCamp: false);
  final me = buildSoldier(name: 'Cmd Lim', rank: 'CPT');
  final leave = buildStatus(
      soldierId: 'Lee Wei',
      type: 'Leave',
      name: 'Annual Leave',
      start: DateTime(2023, 7, 1),
      end: DateTime(2023, 7, 9));

  List<ParadeEntry> roll({bool withLeave = false}) =>
      paradeRoster([tan, lee, me], [if (withLeave) leave], today);

  late _MockWatch watch;
  late _MockBook book;
  late StreamController<Either<Failure, List<ParadeEntry>>> stream;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const BookInOutParams('', isInsideCamp: true));
  });

  setUp(() {
    watch = _MockWatch();
    book = _MockBook();
    stream = StreamController<Either<Failure, List<ParadeEntry>>>();
    when(() => watch(any())).thenAnswer((_) => stream.stream);
    when(() => book(any())).thenAnswer((_) async => const Right(unit));
  });

  tearDown(() => unawaited(stream.close()));

  NominalRollProvider provider() =>
      NominalRollProvider(watch: watch, bookInOut: book, excludeId: 'Cmd Lim');

  group('NominalRollProvider', () {
    test('Name is selected by default; chips replace each other', () async {
      final p = provider();
      stream.add(Right(roll()));
      await Future<void>.delayed(Duration.zero);
      expect(p.category, SearchCategory.name);
      expect(p.visible.map((e) => e.soldier), [tan, lee]);

      p
        ..selectCategory(SearchCategory.appointment)
        ..search('platoon');
      expect(p.category, SearchCategory.appointment);
      expect(p.visible.map((e) => e.soldier), [lee]);
      p.selectCategory(SearchCategory.rank);
      expect(p.visible, isEmpty);
      p.dispose();
    });

    test('nothing is visible before the roster arrives', () {
      final p = provider();
      expect(p.visible, isEmpty);
      p.dispose();
    });

    test('setInCamp books in or out through the use case (R10)', () async {
      final p = provider();
      expect(await p.setInCamp('Lee Wei', true), isNull);
      verify(() => book(const BookInOutParams('Lee Wei', isInsideCamp: true)))
          .called(1);
      when(() => book(any()))
          .thenAnswer((_) async => const Left(ServerFailure('down')));
      expect(await p.setInCamp('Lee Wei', false), 'down');
      p.dispose();
    });
  });

  Future<RouteRecorder> pumpPage(
    WidgetTester tester, {
    ThemeMode mode = ThemeMode.dark,
    Either<Failure, List<ParadeEntry>>? first,
  }) async {
    final recorder = RouteRecorder();
    await tester.pumpApp(
      ChangeNotifierProvider(
        create: (_) => provider(),
        child: const NominalRollPage(),
      ),
      mode: mode,
      observers: [recorder],
    );
    stream.add(first ?? Right(roll(withLeave: true)));
    await tester.pumpAndSettle();
    return recorder;
  }

  Finder inRow(String id, Type type) => find.descendant(
      of: find.byKey(Key('soldierTile-$id')), matching: find.byType(type));

  bool switchValue(WidgetTester tester, String id) =>
      tester.widget<Switch>(find.byKey(Key('inCampToggle-$id'))).value;

  bool chipSelected(WidgetTester tester, String key) =>
      tester.widget<ChoiceChip>(find.byKey(Key('chip-$key'))).selected;

  group('NominalRollPage', () {
    testWidgets('lists every soldier but the commander as a row',
        (tester) async {
      await pumpPage(tester, mode: themeModes.currentValue!);
      expect(find.byKey(const Key('soldierTile-Tan Ah Kow')), findsOneWidget);
      expect(find.byKey(const Key('soldierTile-Lee Wei')), findsOneWidget);
      expect(find.byKey(const Key('soldierTile-Cmd Lim')), findsNothing);
      expect(find.text('Cmd Lim'), findsNothing);
    }, variant: themeModes);

    testWidgets('a row has a plate, the name, a rank chip and an appointment',
        (tester) async {
      await pumpPage(tester);
      expect(inRow('Tan Ah Kow', RankPlate), findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const Key('soldierTile-Tan Ah Kow')),
              matching: find.text('Tan Ah Kow')),
          findsOneWidget);
      expect(
          tester.widget<RankChip>(inRow('Tan Ah Kow', RankChip)).rank, 'CPL');
      expect(
          find.descendant(
              of: find.byKey(const Key('soldierTile-Tan Ah Kow')),
              matching: find.text('Section IC')),
          findsOneWidget);
      expect(inRow('Tan Ah Kow', StateChip), findsNothing);
    });

    testWidgets('a soldier on a status shows it instead of the appointment',
        (tester) async {
      await pumpPage(tester);
      expect(tester.widget<StateChip>(inRow('Lee Wei', StateChip)).label,
          'Annual Leave');
      expect(
          find.descendant(
              of: find.byKey(const Key('soldierTile-Lee Wei')),
              matching: find.text('Platoon Commander')),
          findsNothing);
    });

    testWidgets('the switch follows the booked-in flag', (tester) async {
      await pumpPage(tester);
      expect(switchValue(tester, 'Tan Ah Kow'), isTrue);
      expect(switchValue(tester, 'Lee Wei'), isFalse);
    });

    testWidgets('the header names the columns and the tally counts booked in',
        (tester) async {
      await pumpPage(tester);
      expect(find.text('SOLDIER'), findsOneWidget);
      expect(find.text('BOOKED IN'), findsOneWidget);
      expect(find.text('Booked in'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.byKey(const ValueKey('tick-0-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('tick-0-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('tick-0-2')), findsNothing);
    });

    testWidgets('search mode chips: Name on by default, one at a time',
        (tester) async {
      await pumpPage(tester);
      expect(find.text('Search mode'), findsOneWidget);
      expect(find.text('Search Mode: '), findsNothing);
      expect(chipSelected(tester, 'name'), isTrue);

      await tester.ensureVisible(find.byKey(const Key('chip-rank')));
      await tester.tap(find.byKey(const Key('chip-rank')));
      await tester.pumpAndSettle();
      expect(chipSelected(tester, 'rank'), isTrue);
      expect(chipSelected(tester, 'name'), isFalse);
    });

    testWidgets('the search hint names the chosen mode', (tester) async {
      await pumpPage(tester);
      expect(find.text('Search Name'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chip-rank')));
      await tester.pumpAndSettle();
      expect(find.text('Search Rank'), findsOneWidget);
    });

    testWidgets('searching narrows the rows but not the tally', (tester) async {
      await pumpPage(tester);
      await tester.enterText(find.byKey(const Key('rosterSearch')), 'lee');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('soldierTile-Lee Wei')), findsOneWidget);
      expect(find.byKey(const Key('soldierTile-Tan Ah Kow')), findsNothing);
      expect(find.text('1 / 2'), findsOneWidget);
    });

    testWidgets('search with no match shows the source message',
        (tester) async {
      await pumpPage(tester);
      await tester.enterText(find.byKey(const Key('rosterSearch')), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No results Found!'), findsOneWidget);
      expect(find.byKey(const Key('soldierTile-Lee Wei')), findsNothing);
    });

    testWidgets('tapping a row opens that soldier', (tester) async {
      final recorder = await pumpPage(tester);
      await tester.tap(find.byKey(const Key('soldierTile-Lee Wei')));
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.soldierProfile);
      expect(recorder.lastArguments, 'Lee Wei');
    });

    testWidgets('the switch books the soldier in', (tester) async {
      final recorder = await pumpPage(tester);
      await tester.tap(find.byKey(const Key('inCampToggle-Lee Wei')));
      await tester.pumpAndSettle();
      verify(() => book(const BookInOutParams('Lee Wei', isInsideCamp: true)))
          .called(1);
      expect(find.text('Lee Wei booked in'), findsOneWidget);
      expect(recorder.names.last, isNot(AppRoutes.soldierProfile));
    });

    testWidgets('the switch books a booked-in soldier out', (tester) async {
      await pumpPage(tester);
      await tester.tap(find.byKey(const Key('inCampToggle-Tan Ah Kow')));
      await tester.pumpAndSettle();
      verify(() =>
              book(const BookInOutParams('Tan Ah Kow', isInsideCamp: false)))
          .called(1);
      expect(find.text('Tan Ah Kow booked out'), findsOneWidget);
    });

    testWidgets('a failed booking shows the error snackbar', (tester) async {
      when(() => book(any()))
          .thenAnswer((_) async => const Left(ServerFailure('No network')));
      await pumpPage(tester);
      await tester.tap(find.byKey(const Key('inCampToggle-Lee Wei')));
      await tester.pumpAndSettle();
      expect(find.text('No network'), findsOneWidget);
      expect(find.text('Lee Wei booked in'), findsNothing);
    });

    testWidgets('a failed roster stream shows the error', (tester) async {
      await pumpPage(tester,
          first: const Left(ServerFailure('Nominal roll down')));
      expect(
          find.widgetWithText(ErrorView, 'Nominal roll down'), findsOneWidget);
      expect(find.byKey(const Key('soldierTile-Tan Ah Kow')), findsNothing);
    });

    testWidgets('the scan button opens the QR scanner', (tester) async {
      final recorder = await pumpPage(tester);
      await tester.tap(find.byKey(const Key('scanQr')));
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.qrScanner);
    });
  });
}

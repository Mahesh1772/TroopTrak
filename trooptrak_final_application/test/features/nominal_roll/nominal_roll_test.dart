import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/watch_soldiers_in_camp.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/services/roster_filter.dart';
import 'package:trooptrak_final_application/features/nominal_roll/presentation/pages/nominal_roll_page.dart';
import 'package:trooptrak_final_application/features/nominal_roll/presentation/providers/nominal_roll_provider.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';

import '../../helpers/builders.dart';
import '../../helpers/pump_app.dart';

class _MockWatch extends Mock implements WatchSoldiersInCamp {}

class _MockBook extends Mock implements BookInOut {}

void main() {
  final tan = buildSoldier(name: 'Tan Ah Kow', rank: 'CPL');
  final lee = buildSoldier(
      name: 'Lee Wei',
      rank: '2LT',
      company: 'Bravo',
      platoon: '3',
      section: '4',
      appointment: 'Platoon Commander',
      rationType: 'SD VC',
      bloodGroup: 'AB-',
      isInCamp: false);
  final me = buildSoldier(name: 'Cmd Lim', rank: 'CPT');

  group('filterRoster (R12)', () {
    final all = [tan, lee, me];

    for (final (category, query, expected) in [
      (SearchCategory.name, 'tan ah', 'Tan Ah Kow'),
      (SearchCategory.rank, '2lt', 'Lee Wei'),
      (SearchCategory.company, 'BRAVO', 'Lee Wei'),
      (SearchCategory.section, '4', 'Lee Wei'),
      (SearchCategory.platoon, '3', 'Lee Wei'),
      (SearchCategory.ration, 'vc', 'Lee Wei'),
      (SearchCategory.blood, 'ab-', 'Lee Wei'),
      (SearchCategory.appointment, 'platoon', 'Lee Wei'),
    ]) {
      test('${category.label} searches its own field', () {
        expect(
            filterRoster(all,
                    query: query, category: category, excludeId: 'Cmd Lim')
                .map((s) => s.name),
            [expected]);
      });
    }

    test('empty query lists everyone except the signed-in commander', () {
      expect(
          filterRoster(all,
              query: '', category: SearchCategory.name, excludeId: 'Cmd Lim'),
          [tan, lee]);
    });

    test('chip labels follow the source order', () {
      expect(SearchCategory.values.map((c) => c.label), [
        'Name',
        'Rank',
        'Company',
        'Section',
        'Platoon',
        'Ration',
        'Blood',
        'Appointment',
      ]);
    });
  });

  late _MockWatch watch;
  late _MockBook book;
  late StreamController<Either<Failure, List<Soldier>>> roster;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const BookInOutParams('', isInsideCamp: true));
  });

  setUp(() {
    watch = _MockWatch();
    book = _MockBook();
    roster = StreamController<Either<Failure, List<Soldier>>>();
    when(() => watch(any())).thenAnswer((_) => roster.stream);
    when(() => book(any())).thenAnswer((_) async => const Right(unit));
  });

  tearDown(() => unawaited(roster.close()));

  NominalRollProvider provider() =>
      NominalRollProvider(watch: watch, bookInOut: book, excludeId: 'Cmd Lim');

  group('NominalRollProvider', () {
    test('Name is selected by default; chips replace each other', () async {
      final p = provider();
      roster.add(Right([tan, lee, me]));
      await Future<void>.delayed(Duration.zero);
      expect(p.category, SearchCategory.name);
      expect(p.visible, [tan, lee]);

      p
        ..selectCategory(SearchCategory.company)
        ..search('bravo');
      expect(p.category, SearchCategory.company);
      expect(p.visible, [lee]);
      p.selectCategory(SearchCategory.rank);
      expect(p.visible, isEmpty);
      p.dispose();
    });

    test('setInCamp books in or out through the use case (R10)', () async {
      final p = provider();
      expect(await p.setInCamp(lee, true), isNull);
      verify(() => book(const BookInOutParams('Lee Wei', isInsideCamp: true)))
          .called(1);
      when(() => book(any()))
          .thenAnswer((_) async => const Left(ServerFailure('down')));
      expect(await p.setInCamp(lee, false), 'down');
      p.dispose();
    });
  });

  Future<RouteRecorder> pumpPage(WidgetTester tester,
      {ThemeMode mode = ThemeMode.dark}) async {
    final recorder = RouteRecorder();
    await tester.pumpApp(
      ChangeNotifierProvider(
        create: (_) => provider(),
        child: const NominalRollPage(),
      ),
      mode: mode,
      observers: [recorder],
    );
    roster.add(Right([tan, lee, me]));
    await tester.pumpAndSettle();
    return recorder;
  }

  group('NominalRollPage', () {
    testWidgets('grid shows every soldier but the commander, with labels',
        (tester) async {
      await pumpPage(tester, mode: themeModes.currentValue!);
      expect(find.text('Tan Ah Kow'), findsOneWidget);
      expect(find.text('Lee Wei'), findsOneWidget);
      expect(find.text('Cmd Lim'), findsNothing);
      expect(find.text('IN CAMP'), findsOneWidget);
      expect(find.text('NOT IN CAMP'), findsOneWidget);
      expect(find.text('Search Mode: '), findsOneWidget);
      expect(
          tester
              .widget<ChoiceChip>(find.byKey(const Key('chip-name')))
              .selected,
          isTrue);
    }, variant: themeModes);

    testWidgets('chips are mutually exclusive', (tester) async {
      await pumpPage(tester);
      await tester.tap(find.byKey(const Key('chip-rank')));
      await tester.pumpAndSettle();
      bool selected(String key) =>
          tester.widget<ChoiceChip>(find.byKey(Key('chip-$key'))).selected;
      expect(selected('rank'), isTrue);
      expect(selected('name'), isFalse);
    });

    testWidgets('search with no match shows the source message',
        (tester) async {
      await pumpPage(tester);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No results Found!'), findsOneWidget);
    });

    testWidgets('tapping a tile opens that soldier', (tester) async {
      final recorder = await pumpPage(tester);
      await tester.tap(find.text('Lee Wei'));
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.soldierProfile);
      expect(recorder.lastArguments, 'Lee Wei');
    });

    testWidgets('the toggle books the soldier in', (tester) async {
      await pumpPage(tester);
      final toggle = find.byKey(const Key('inCampToggle-Lee Wei'));
      await tester.tapAt(tester.getTopRight(toggle) + const Offset(-15, 15));
      await tester.pumpAndSettle();
      verify(() => book(const BookInOutParams('Lee Wei', isInsideCamp: true)))
          .called(1);
    });

    testWidgets('the add button opens the QR scanner', (tester) async {
      final recorder = await pumpPage(tester);
      await tester.tap(find.byKey(const Key('scanQr')));
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.qrScanner);
    });
  });
}

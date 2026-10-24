import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/widgets/app_list_card.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/core/widgets/gradient_header.dart';
import 'package:trooptrak_final_application/core/widgets/rank_chip.dart';
import 'package:trooptrak_final_application/core/widgets/rank_plate.dart';
import 'package:trooptrak_final_application/features/conducts/domain/entities/conduct.dart';
import 'package:trooptrak_final_application/features/conducts/domain/repositories/conduct_repository.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/conduct_usecases.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/watch_conduct_breakdown.dart';
import 'package:trooptrak_final_application/features/conducts/presentation/conducts_routes.dart';
import 'package:trooptrak_final_application/features/conducts/presentation/pages/conduct_details_page.dart';
import 'package:trooptrak_final_application/features/conducts/presentation/providers/conduct_details_provider.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/repositories/soldier_repository.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/pump_app.dart';

class _MockConducts extends Mock implements ConductRepository {}

class _MockSoldiers extends Mock implements SoldierRepository {}

class _MockDelete extends Mock implements DeleteConduct {}

void main() {
  final tan = buildSoldier(name: 'Tan Ah Kow');
  final lee = buildSoldier(name: 'Lee Wei', rank: '2LT');
  final lim = buildSoldier(name: 'Lim Bah', rank: 'PTE');
  final conduct = buildConduct(
      participants: ['Tan Ah Kow'], soldierReason: {'Lee Wei': 'OL'});

  test('breakdownOf splits by participant name; search filters both', () {
    final b = breakdownOf(conduct, [tan, lee, lim]);
    expect(b.participants, [tan]);
    expect(b.nonParticipants, [lee, lim]);
    final searched = b.search('li');
    expect(searched.participants, isEmpty);
    expect(searched.nonParticipants, [lim]);
    expect(b.search('zzz').isEmpty, isTrue);
  });

  test('WatchConductBreakdown combines the conduct with live soldiers',
      () async {
    final conducts = _MockConducts();
    final soldiers = _MockSoldiers();
    when(() => conducts.watchById('c1'))
        .thenAnswer((_) => Stream.value(Right<Failure, Conduct>(conduct)));
    when(() => soldiers.watchAll()).thenAnswer(
        (_) => Stream.value(Right<Failure, List<Soldier>>([tan, lee])));
    final first = await WatchConductBreakdown(conducts, soldiers)('c1').first;
    expect(first.getOrElse(() => throw 'x').nonParticipants, [lee]);

    when(() => conducts.watchById('gone')).thenAnswer(
        (_) => Stream.value(const Left<Failure, Conduct>(NotFoundFailure())));
    expect(
        (await WatchConductBreakdown(conducts, soldiers)('gone').first)
            .isLeft(),
        isTrue);
  });

  late StreamController<Either<Failure, ConductBreakdown>> stream;
  late _MockDelete delete;

  setUp(() {
    stream = StreamController<Either<Failure, ConductBreakdown>>();
    delete = _MockDelete();
    when(() => delete(any())).thenAnswer((_) async => const Right(unit));
  });
  tearDown(() => unawaited(stream.close()));

  ConductDetailsProvider provider() {
    final watch = _FakeWatch(stream.stream);
    return ConductDetailsProvider(
        watch: watch, delete: delete, conductId: 'c1');
  }

  Future<RouteRecorder> pumpDetails(WidgetTester tester,
      {bool canManage = true, ThemeMode mode = ThemeMode.dark}) async {
    final recorder = RouteRecorder();
    await tester.pumpApp(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => provider(),
                child: ConductDetailsPage(canManage: canManage),
              ),
            )),
            child: const Text('open'),
          ),
        ),
      ),
      mode: mode,
      observers: [recorder],
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    stream.add(Right(breakdownOf(conduct, [tan, lee, lim])));
    await tester.pumpAndSettle();
    return recorder;
  }

  Future<void> showNonParticipants(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('segment-nonParticipants')));
    await tester.pumpAndSettle();
  }

  Finder inRow(String name, Finder matching) =>
      find.descendant(of: find.byKey(Key('person-$name')), matching: matching);

  Finder inSegment(String value, Finder matching) => find.descendant(
      of: find.byKey(Key('segment-$value')), matching: matching);

  Color tickColor(WidgetTester tester, int index) => (tester
          .widget<AnimatedContainer>(find.byKey(ValueKey('tick-0-$index')))
          .decoration! as BoxDecoration)
      .color!;

  testWidgets('the header shows type, name, date and time', (tester) async {
    await pumpDetails(tester, mode: themeModes.currentValue!);
    expect(find.text('RUN'), findsOneWidget);
    expect(find.text('Morning Run'), findsOneWidget);
    expect(find.text('5 Jul 2023 · 7:00 AM – 8:00 AM'), findsOneWidget);
    expect(find.byType(GradientHeader), findsOneWidget);
    for (final key in ['detailsBack', 'editConduct', 'deleteConduct']) {
      expect(
          find.descendant(
              of: find.byType(GradientHeader), matching: find.byKey(Key(key))),
          findsOneWidget);
    }
  }, variant: themeModes);

  testWidgets('the header strip ticks every soldier and counts who took part',
      (tester) async {
    await pumpDetails(tester);
    expect(find.text('Participation strength'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.byKey(const ValueKey('tick-0-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('tick-0-3')), findsNothing);
    expect([
      for (var i = 0; i < 3; i++) tickColor(tester, i)
    ], [
      AppColors.white,
      AppColors.onGradientTickOff,
      AppColors.onGradientTickOff,
    ]);
  });

  testWidgets('the strip keeps counting everyone while a search is active',
      (tester) async {
    await pumpDetails(tester);
    await tester.enterText(find.byKey(const Key('detailsSearch')), 'lim');
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.byKey(const ValueKey('tick-0-2')), findsOneWidget);
  });

  testWidgets('the switch counts each group and opens on participants',
      (tester) async {
    await pumpDetails(tester);
    expect(
        inSegment('participants', find.text('Participants')), findsOneWidget);
    expect(inSegment('participants', find.text('1')), findsOneWidget);
    expect(inSegment('nonParticipants', find.text('Non-Participants')),
        findsOneWidget);
    expect(inSegment('nonParticipants', find.text('2')), findsOneWidget);
    expect(find.byKey(const Key('person-Tan Ah Kow')), findsOneWidget);
    expect(find.byKey(const Key('person-Lee Wei')), findsNothing);
    expect(find.byKey(const Key('person-Lim Bah')), findsNothing);
  });

  testWidgets('a participant row shows plate, name, rank chip and appointment',
      (tester) async {
    await pumpDetails(tester, mode: themeModes.currentValue!);
    expect(inRow('Tan Ah Kow', find.byType(RankPlate)), findsOneWidget);
    expect(inRow('Tan Ah Kow', find.text('Tan Ah Kow')), findsOneWidget);
    expect(inRow('Tan Ah Kow', find.byType(RankChip)), findsOneWidget);
    expect(inRow('Tan Ah Kow', find.text('CPL')), findsOneWidget);
    expect(inRow('Tan Ah Kow', find.text('Section IC')), findsOneWidget);
  }, variant: themeModes);

  testWidgets('non-participants show why: the status, or removed',
      (tester) async {
    await pumpDetails(tester);
    await showNonParticipants(tester);
    expect(find.byKey(const Key('person-Tan Ah Kow')), findsNothing);
    expect(inRow('Lee Wei', find.text('OL')), findsOneWidget);
    expect(inRow('Lee Wei', find.text('2LT')), findsOneWidget);
    expect(inRow('Lim Bah', find.text('Removed from conduct')), findsOneWidget);
    expect(inRow('Lim Bah', find.text('PTE')), findsOneWidget);
    expect(find.text('Section IC'), findsNothing);
  });

  testWidgets('switching back lists the participants again', (tester) async {
    await pumpDetails(tester);
    await showNonParticipants(tester);
    await tester.tap(find.byKey(const Key('segment-participants')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('person-Tan Ah Kow')), findsOneWidget);
    expect(find.byKey(const Key('person-Lee Wei')), findsNothing);
  });

  testWidgets('search filters the open group and the counts', (tester) async {
    await pumpDetails(tester);
    await showNonParticipants(tester);
    await tester.enterText(find.byKey(const Key('detailsSearch')), 'lim');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('person-Lim Bah')), findsOneWidget);
    expect(find.byKey(const Key('person-Lee Wei')), findsNothing);
    expect(inSegment('nonParticipants', find.text('1')), findsOneWidget);
    expect(inSegment('participants', find.text('0')), findsOneWidget);
  });

  testWidgets('no match shows the source message', (tester) async {
    await pumpDetails(tester);
    await tester.enterText(find.byKey(const Key('detailsSearch')), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Nothing to see here...yet.'), findsOneWidget);
    expect(find.byType(AppListCard), findsNothing);
    expect(find.byKey(const Key('person-Tan Ah Kow')), findsNothing);
  });

  testWidgets('a group with nobody shows the source message', (tester) async {
    await pumpDetails(tester);
    stream.add(Right(breakdownOf(conduct, [tan])));
    await tester.pumpAndSettle();
    await showNonParticipants(tester);
    expect(find.text('Nothing to see here...yet.'), findsOneWidget);
  });

  group('ConductDetailsProvider', () {
    test('lists the participants first; select and search narrow the rows',
        () async {
      final p = provider();
      addTearDown(p.dispose);
      expect(p.rows, isEmpty);
      expect(p.visible, isNull);
      stream.add(Right(breakdownOf(conduct, [tan, lee, lim])));
      await Future<void>.delayed(Duration.zero);
      expect(p.group, ConductGroup.participants);
      expect(p.rows, [tan]);
      p.select(ConductGroup.nonParticipants);
      expect(p.rows, [lee, lim]);
      p.search('LIM');
      expect(p.query, 'LIM');
      expect(p.rows, [lim]);
      p.select(ConductGroup.participants);
      expect(p.rows, isEmpty);
    });

    test('select and search tell their listeners', () {
      final p = provider();
      addTearDown(p.dispose);
      var calls = 0;
      p.addListener(() => calls++);
      p.select(ConductGroup.nonParticipants);
      p.search('a');
      expect(calls, 2);
    });
  });

  testWidgets('edit opens the conduct form with this conduct', (tester) async {
    final recorder = await pumpDetails(tester);
    await tester.tap(find.byKey(const Key('editConduct')));
    await tester.pumpAndSettle();
    expect(recorder.names.last, AppRoutes.editConduct);
    expect(recorder.lastArguments, conduct);
  });

  testWidgets('delete asks first, then deletes and closes', (tester) async {
    await pumpDetails(tester);
    await tester.tap(find.byKey(const Key('deleteConduct')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => delete(any()));

    await tester.tap(find.byKey(const Key('deleteConduct')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    verify(() => delete('c1')).called(1);
    expect(find.byType(ConductDetailsPage), findsNothing);
    expect(find.text('Morning Run deleted'), findsOneWidget);
  });

  testWidgets('a failed delete shows the error and stays', (tester) async {
    when(() => delete(any()))
        .thenAnswer((_) async => const Left(ServerFailure('No network')));
    await pumpDetails(tester);
    await tester.tap(find.byKey(const Key('deleteConduct')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No network'), findsOneWidget);
    expect(find.byType(ConductDetailsPage), findsOneWidget);
  });

  testWidgets('a failed breakdown stream shows the error', (tester) async {
    await tester.pumpApp(ChangeNotifierProvider(
      create: (_) => provider(),
      child: const ConductDetailsPage(),
    ));
    stream.add(const Left(NotFoundFailure('Conduct not found')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ErrorView, 'Conduct not found'), findsOneWidget);
  });

  testWidgets('read-only details hide edit and delete', (tester) async {
    await pumpDetails(tester, canManage: false);
    expect(find.byKey(const Key('editConduct')), findsNothing);
    expect(find.byKey(const Key('deleteConduct')), findsNothing);
  });

  for (final (route, canManage) in [
    (AppRoutes.conductDetails, true),
    (AppRoutes.conductDetailsReadOnly, false),
  ]) {
    testWidgets('$route opens the details with canManage $canManage',
        (tester) async {
      await tester.pumpApp(
        Builder(builder: (context) => conductRoutes[route]!(context, 'c1')),
        providers: [
          Provider<WatchConductBreakdown>.value(
              value: _FakeWatch(stream.stream)),
          Provider<DeleteConduct>.value(value: delete),
        ],
      );
      expect(
          tester
              .widget<ConductDetailsPage>(find.byType(ConductDetailsPage))
              .canManage,
          canManage);
    });
  }
}

class _FakeWatch implements WatchConductBreakdown {
  _FakeWatch(this._stream);

  final Stream<Either<Failure, ConductBreakdown>> _stream;

  @override
  Stream<Either<Failure, ConductBreakdown>> call(String conductId) => _stream;
}

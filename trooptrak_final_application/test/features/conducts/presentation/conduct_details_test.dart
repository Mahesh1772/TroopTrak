import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
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

  testWidgets('header, participants and non-participants with reasons',
      (tester) async {
    await pumpDetails(tester, mode: themeModes.currentValue!);
    expect(find.text('RUN'), findsOneWidget);
    expect(find.text('Morning Run'), findsOneWidget);
    expect(find.text('5 JUL 2023'), findsOneWidget);
    expect(find.text('Participants'), findsOneWidget);
    expect(find.text('Non-Participants'), findsOneWidget);
    expect(find.byKey(const Key('person-Tan Ah Kow')), findsOneWidget);
    expect(find.text('OL'), findsOneWidget);
    expect(find.text('Removed from conduct'), findsOneWidget);
  }, variant: themeModes);

  testWidgets('search filters; no match shows the source message',
      (tester) async {
    await pumpDetails(tester);
    await tester.enterText(find.byType(TextField), 'lim');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('person-Lim Bah')), findsOneWidget);
    expect(find.byKey(const Key('person-Tan Ah Kow')), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Nothing to see here...yet.'), findsOneWidget);
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

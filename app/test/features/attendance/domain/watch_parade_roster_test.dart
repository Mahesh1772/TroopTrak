import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/error/result.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/watch_parade_roster.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/watch_soldiers_in_camp.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/repositories/status_repository.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_roster.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_state.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';

class _MockSoldiers extends Mock implements WatchSoldiersInCamp {}

class _MockStatuses extends Mock implements StatusRepository {}

void main() {
  final now = DateTime(2023, 7, 5, 9);
  final tan = buildSoldier(name: 'Tan');
  final lee = buildSoldier(name: 'Lee', isInCamp: false);
  final leave = buildStatus(soldierId: 'Tan', type: 'Leave', name: 'OL');

  late _MockSoldiers soldiers;
  late _MockStatuses statuses;
  late StreamController<Either<Failure, List<Soldier>>> soldierStream;
  late StreamController<Either<Failure, List<Status>>> statusStream;
  late FixedClock clock;

  setUp(() {
    soldiers = _MockSoldiers();
    statuses = _MockStatuses();
    soldierStream = StreamController.broadcast();
    statusStream = StreamController.broadcast();
    clock = FixedClock(now);
    when(() => soldiers(const NoParams()))
        .thenAnswer((_) => soldierStream.stream);
    when(() => statuses.watchAll()).thenAnswer((_) => statusStream.stream);
  });

  tearDown(() async {
    await soldierStream.close();
    await statusStream.close();
  });

  ResultStream<List<ParadeEntry>> watch() =>
      WatchParadeRoster(soldiers, statuses, clock)(const NoParams());

  test('combines soldiers with their current statuses', () async {
    final first = watch().first;
    soldierStream.add(Right([tan, lee]));
    statusStream.add(Right([leave]));

    expect((await first).getOrElse(() => throw 'x'), [
      ParadeEntry(soldier: tan, statuses: [leave], state: ParadeState.leave),
      ParadeEntry(soldier: lee, statuses: const [], state: ParadeState.out),
    ]);
  });

  test('re-emits on either change and reads the clock each time', () async {
    final emitted = <List<ParadeEntry>>[];
    final sub = watch().listen((e) => emitted.add(e.getOrElse(() => [])));
    soldierStream.add(Right([tan]));
    statusStream.add(Right([leave]));
    await Future<void>.delayed(Duration.zero);
    clock.set(DateTime(2023, 7, 8));
    statusStream.add(Right([leave]));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(emitted.map((e) => e.single.state),
        [ParadeState.leave, ParadeState.inCamp]);
  });

  test('a soldiers failure is passed through', () async {
    final first = watch().first;
    soldierStream.add(const Left(ServerFailure('soldiers down')));
    statusStream.add(const Right([]));

    expect(await first,
        const Left<Failure, List<ParadeEntry>>(ServerFailure('soldiers down')));
  });

  test('a statuses failure is passed through', () async {
    final first = watch().first;
    soldierStream.add(Right([tan]));
    statusStream.add(const Left(ServerFailure('statuses down')));

    expect(await first,
        const Left<Failure, List<ParadeEntry>>(ServerFailure('statuses down')));
  });
}

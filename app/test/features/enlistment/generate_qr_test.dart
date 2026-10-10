import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_router.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/services/id_generator.dart';
import 'package:trooptrak_final_application/core/services/tick_source.dart';
import 'package:trooptrak_final_application/core/widgets/hero_dialog_route.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/repositories/men_repository.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/usecases/men_usecases.dart';
import 'package:trooptrak_final_application/features/enlistment/presentation/pages/generate_qr_page.dart';
import 'package:trooptrak_final_application/features/enlistment/presentation/providers/enlistment_qr_provider.dart';

import '../../helpers/fake_clock.dart';
import '../../helpers/fake_tick_source.dart';
import '../../helpers/pump_app.dart';

class _MockMen extends Mock implements MenRepository {}

class _MockPublish extends Mock implements PublishEnlistmentQr {}

class _MockClear extends Mock implements ClearEnlistmentQr {}

class _FixedIds implements IdGenerator {
  @override
  String next() => 'qr-fixed';
}

void main() {
  group('core services', () {
    test('UuidGenerator gives distinct v4 ids', () {
      const ids = UuidGenerator();
      final a = ids.next();
      expect(a, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-')));
      expect(ids.next(), isNot(a));
    });

    test('PeriodicTickSource beats every period', () async {
      final beats = await const PeriodicTickSource()
          .every(const Duration(milliseconds: 10))
          .take(3)
          .length;
      expect(beats, 3);
    });
  });

  group('QR use cases (R15)', () {
    late _MockMen men;
    setUp(() => men = _MockMen());

    test('publish writes a fresh code and returns it', () async {
      when(() => men.setQrId('uid-1', 'qr-fixed'))
          .thenAnswer((_) async => const Right(unit));
      expect(await PublishEnlistmentQr(men, _FixedIds())('uid-1'),
          const Right<Failure, String>('qr-fixed'));
    });

    test('publish passes a write failure on', () async {
      when(() => men.setQrId(any(), any()))
          .thenAnswer((_) async => const Left(ServerFailure('offline')));
      expect(await PublishEnlistmentQr(men, _FixedIds())('uid-1'),
          const Left<Failure, String>(ServerFailure('offline')));
    });

    test('clear sets QRid to null', () async {
      when(() => men.setQrId('uid-1', null))
          .thenAnswer((_) async => const Right(unit));
      expect(await ClearEnlistmentQr(men)('uid-1'),
          const Right<Failure, Unit>(unit));
    });
  });

  late FixedClock clock;
  late FakeTickSource ticks;
  late _MockPublish publish;
  late _MockClear clear;

  setUp(() {
    clock = FixedClock(DateTime(2023, 7, 5, 9));
    ticks = FakeTickSource(clock);
    publish = _MockPublish();
    clear = _MockClear();
    when(() => publish(any())).thenAnswer((_) async => const Right('qr-123'));
    when(() => clear(any())).thenAnswer((_) async => const Right(unit));
  });

  EnlistmentQrProvider provider() => EnlistmentQrProvider(
        uid: 'uid-1',
        publish: publish,
        clear: clear,
        clock: clock,
        ticks: ticks,
      );

  group('EnlistmentQrProvider', () {
    test('publishes for the soldier and starts at 02:00', () async {
      final qr = provider();
      await qr.start();
      verify(() => publish('uid-1')).called(1);
      expect(qr.code, 'qr-123');
      expect(qr.countdown, '02:00');
      qr.dispose();
    });

    test('counts down each second and expires after two minutes', () async {
      final qr = provider();
      await qr.start();
      ticks.tick();
      expect(qr.countdown, '01:59');
      ticks.tick(59);
      expect(qr.countdown, '01:00');
      ticks.tick(60);
      expect(qr.countdown, '00:00');
      expect(qr.expired, isFalse);
      verifyNever(() => clear(any()));

      ticks.tick();
      expect(qr.expired, isTrue);
      verify(() => clear('uid-1')).called(1);
      expect(ticks.hasListener, isFalse);

      qr.dispose();
      verifyNever(() => clear(any()));
    });

    test('a late tick still shows the second it is in', () async {
      final qr = provider();
      await qr.start();
      clock.advance(const Duration(milliseconds: 4));
      ticks.tick();
      expect(qr.countdown, '01:59');
      qr.dispose();
    });

    test('dispose before expiry withdraws the code once', () async {
      final qr = provider();
      await qr.start();
      ticks.tick(30);
      qr.dispose();
      verify(() => clear('uid-1')).called(1);
      expect(ticks.hasListener, isFalse);
    });

    test('dispose while publishing still withdraws the code', () async {
      final pending = Completer<Either<Failure, String>>();
      when(() => publish(any())).thenAnswer((_) => pending.future);
      final qr = provider();
      final started = qr.start();
      qr.dispose();
      verify(() => clear('uid-1')).called(1);
      pending.complete(const Right('qr-123'));
      await started;
    });

    test('a failed publish shows the error and stops counting', () async {
      when(() => publish(any()))
          .thenAnswer((_) async => const Left(ServerFailure('offline')));
      final qr = provider();
      await qr.start();
      expect(qr.code, isNull);
      expect(qr.error, 'offline');
      expect(ticks.hasListener, isFalse);
      qr.dispose();
      verifyNever(() => clear(any()));
    });
  });

  group('GenerateQrPage', () {
    Future<RouteRecorder> pumpDialog(WidgetTester tester,
        {ThemeMode mode = ThemeMode.dark}) async {
      final recorder = RouteRecorder();
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(HeroDialogRoute<void>(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => provider()..start(),
                  child: const GenerateQrPage(),
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
      await tester.pumpAndSettle();
      return recorder;
    }

    testWidgets('shows the code, the help text and the countdown',
        (tester) async {
      await pumpDialog(tester, mode: themeModes.currentValue!);
      expect(find.text('ADD A NEW SOLDIER'), findsOneWidget);
      expect(find.byKey(const Key('qrImage')), findsOneWidget);
      expect(find.textContaining('Have a commander scan'), findsOneWidget);
      expect(find.text('QR will vanish in:'), findsOneWidget);
      expect(find.text('02:00'), findsOneWidget);

      ticks.tick();
      await tester.pump();
      expect(find.text('01:59'), findsOneWidget);
    }, variant: themeModes);

    testWidgets('close pops the dialog and withdraws the code', (tester) async {
      await pumpDialog(tester);
      await tester.tap(find.byKey(const Key('closeQr')));
      await tester.pumpAndSettle();
      expect(find.text('ADD A NEW SOLDIER'), findsNothing);
      expect(find.text('open'), findsOneWidget);
      verify(() => clear('uid-1')).called(1);
    });

    testWidgets('tapping outside also withdraws the code', (tester) async {
      await pumpDialog(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('ADD A NEW SOLDIER'), findsNothing);
      verify(() => clear('uid-1')).called(1);
    });

    testWidgets('expiry closes the dialog', (tester) async {
      await pumpDialog(tester);
      ticks.tick(121);
      await tester.pumpAndSettle();
      expect(find.text('ADD A NEW SOLDIER'), findsNothing);
      verify(() => clear('uid-1')).called(1);
    });

    testWidgets('a failed publish shows the error in place of the code',
        (tester) async {
      when(() => publish(any()))
          .thenAnswer((_) async => const Left(ServerFailure('offline')));
      await pumpDialog(tester);
      expect(find.byKey(const Key('qrImage')), findsNothing);
      expect(find.text('offline'), findsOneWidget);
    });
  });

  test('the router opens the QR route as a hero dialog', () {
    final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.generateQr));
    expect(route, isA<HeroDialogRoute<dynamic>>());
    expect(route.settings.name, AppRoutes.generateQr);
    expect(
        AppRouter.onGenerateRoute(
            const RouteSettings(name: AppRoutes.editOwnProfile)),
        isA<MaterialPageRoute<dynamic>>());
  });
}

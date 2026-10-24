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
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_layout.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/hero_dialog_route.dart';
import 'package:trooptrak_final_application/core/widgets/hero_sheet.dart';
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

    test('fraction is the share of the two minutes still left', () async {
      final qr = provider();
      expect(qr.fraction, 1);
      await qr.start();
      expect(qr.fraction, 1);
      ticks.tick(30);
      expect(qr.fraction, 0.75);
      ticks.tick(30);
      expect(qr.fraction, 0.5);
      ticks.tick(60);
      expect(qr.fraction, 0);
      qr.dispose();
    });

    test('fraction never leaves 0 to 1, whatever the lifetime', () async {
      final late = provider();
      await late.start();
      clock.advance(const Duration(seconds: 30));
      ticks.tick();
      expect(late.fraction, closeTo(89 / 120, 1e-9));
      late.dispose();

      final instant = EnlistmentQrProvider(
        uid: 'uid-1',
        publish: publish,
        clear: clear,
        clock: clock,
        ticks: ticks,
        lifetime: Duration.zero,
      );
      expect(instant.fraction, 0);
      instant.dispose();
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

    testWidgets('is a bottom sheet: sheet colour, 28 px top corners, handle',
        (tester) async {
      final mode = themeModes.currentValue!;
      await pumpDialog(tester, mode: mode);
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      final sheet = find
          .descendant(
              of: find.byType(HeroSheet), matching: find.byType(Material))
          .first;
      final material = tester.widget<Material>(sheet);
      expect(material.color, palette.sheet);
      expect(
        material.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      );
      expect(tester.getBottomLeft(sheet).dy, 844);
      expect(tester.getSize(sheet).width, 390);
      expect(tester.getTopLeft(sheet).dy, greaterThan(0));
      expect(find.byKey(const Key('sheetHandle')), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      expect(
        find
            .descendant(of: find.byType(HeroSheet), matching: find.byType(Hero))
            .evaluate()
            .single
            .widget,
        isA<Hero>().having((h) => h.tag, 'tag', GenerateQrPage.heroTag),
      );
    }, variant: themeModes);

    testWidgets('the sheet flies in from the SHOW QR CODE pill',
        (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: Hero(
              tag: GenerateQrPage.heroTag,
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).push(HeroDialogRoute<void>(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => provider()..start(),
                    child: const GenerateQrPage(),
                  ),
                )),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('qrImage')), findsOneWidget);
      await tester.tap(find.byKey(const Key('closeQr')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('qrImage')), findsNothing);
    });

    testWidgets('the route dims the page with the sheet scrim', (tester) async {
      final recorder = await pumpDialog(tester);
      final route = recorder.pushed.last as HeroDialogRoute<void>;
      expect(route.barrierColor, AppColors.scrim);
      expect(route.opaque, isFalse);
      expect(route.barrierDismissible, isTrue);
    });

    testWidgets('the code sits on a white tile of its own size',
        (tester) async {
      await pumpDialog(tester, mode: themeModes.currentValue!);
      final tile = find
          .ancestor(
              of: find.byKey(const Key('qrImage')),
              matching: find.byType(DecoratedBox))
          .first;
      expect(
          (tester.widget<DecoratedBox>(tile).decoration as BoxDecoration).color,
          AppColors.white);
      expect(tester.getSize(tile), const Size.square(AppLayout.qrTile));
      expect(tester.getCenter(tile).dx, 195);
    }, variant: themeModes);

    testWidgets('the countdown is a tabular accent figure', (tester) async {
      final mode = themeModes.currentValue!;
      await pumpDialog(tester, mode: mode);
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      final style =
          tester.widget<Text>(find.byKey(const Key('qrCountdown'))).style!;
      expect(style.color, palette.accentText);
      expect(style.fontSize, AppLayout.qrCountdownFigure);
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    }, variant: themeModes);

    testWidgets('the bar drains as the seconds go', (tester) async {
      await pumpDialog(tester, mode: themeModes.currentValue!);
      double factor() => tester
          .widget<AnimatedFractionallySizedBox>(
              find.byKey(const Key('qrDrain')))
          .widthFactor!;
      expect(factor(), 1);
      expect(tester.getSize(find.byKey(const Key('qrDrain'))).height,
          AppLayout.qrDrainBar);

      ticks.tick(30);
      await tester.pump();
      expect(find.text('01:30'), findsOneWidget);
      expect(factor(), 0.75);

      ticks.tick(60);
      await tester.pump();
      expect(find.text('00:30'), findsOneWidget);
      expect(factor(), 0.25);
      await tester.pump(const Duration(seconds: 1));
      final track = tester.getSize(find
          .ancestor(
              of: find.byKey(const Key('qrDrain')),
              matching: find.byType(DecoratedBox))
          .first);
      expect(tester.getSize(find.byKey(const Key('qrDrain'))).width,
          closeTo(track.width * 0.25, 0.01));
    }, variant: themeModes);

    testWidgets('close pops the sheet and withdraws the code', (tester) async {
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

    testWidgets('expiry closes the sheet', (tester) async {
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

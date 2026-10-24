import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/primary_button.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/entities/soldier_registration.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/repositories/men_repository.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/usecases/men_usecases.dart';
import 'package:trooptrak_final_application/features/enlistment/presentation/pages/qr_scanner_page.dart';
import 'package:trooptrak_final_application/features/enlistment/presentation/providers/qr_scan_provider.dart';
import 'package:trooptrak_final_application/features/enlistment/presentation/widgets/qr_scanner_overlay.dart';
import 'package:trooptrak_final_application/features/enlistment/presentation/widgets/scanner_footer.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';

import '../../helpers/builders.dart';
import '../../helpers/pump_app.dart';

class _MockMen extends Mock implements MenRepository {}

class _MockFind extends Mock implements FindRegistrationByQr {}

void main() {
  final registration = SoldierRegistration(
      uid: 'uid-1', profile: buildSoldier(name: 'Lim Bah'), qrId: 'qr-123');

  group('FindRegistrationByQr (R15)', () {
    late _MockMen men;
    setUp(() => men = _MockMen());

    test('looks up the trimmed code', () async {
      when(() => men.findByQrId('qr-123'))
          .thenAnswer((_) async => Right(registration));
      expect(await FindRegistrationByQr(men)('  qr-123 '),
          Right<Failure, SoldierRegistration?>(registration));
    });

    test('an empty code is simply not found', () async {
      expect(await FindRegistrationByQr(men)('  '),
          const Right<Failure, SoldierRegistration?>(null));
      verifyZeroInteractions(men);
    });

    test('WatchOwnRegistration streams the profile of Men/{uid}', () async {
      when(() => men.watch('uid-1'))
          .thenAnswer((_) => Stream.value(Right(registration)));
      expect(await WatchOwnRegistration(men)('uid-1').first,
          Right<Failure, Soldier>(registration.profile));
    });

    test('registrations compare by value', () {
      SoldierRegistration of(String? qr) => SoldierRegistration(
          uid: 'uid-1', profile: buildSoldier(name: 'Lim Bah'), qrId: qr);
      expect(of('qr-123'), registration);
      expect(of(null), isNot(registration));
    });
  });

  late _MockFind lookup;
  setUp(() {
    lookup = _MockFind();
    when(() => lookup(any())).thenAnswer((_) async => Right(registration));
  });

  group('QrScanProvider', () {
    test('found, not found and failure outcomes', () async {
      final p = QrScanProvider(lookup);
      final found = await p.lookup('qr-123');
      expect((found! as ScanFound).profile, registration.profile);

      when(() => lookup(any())).thenAnswer((_) async => const Right(null));
      expect(await p.lookup('nope'), isA<ScanNotFound>());

      when(() => lookup(any()))
          .thenAnswer((_) async => const Left(ServerFailure('down')));
      expect((await p.lookup('x'))! as ScanFailed,
          isA<ScanFailed>().having((f) => f.message, 'message', 'down'));
    });

    test('a second code while one is looked up is ignored', () async {
      final gate = Completer<Either<Failure, SoldierRegistration?>>();
      when(() => lookup(any())).thenAnswer((_) => gate.future);
      final p = QrScanProvider(lookup);
      final first = p.lookup('a');
      expect(p.busy, isTrue);
      expect(await p.lookup('b'), isNull);
      gate.complete(Right(registration));
      expect(await first, isA<ScanFound>());
      verify(() => lookup(any())).called(1);
    });
  });

  group('QrScannerPage', () {
    Future<RouteRecorder> pumpScanner(WidgetTester tester,
        {ThemeMode mode = ThemeMode.dark}) async {
      final recorder = RouteRecorder();
      await tester.pumpApp(
        ChangeNotifierProvider(
          create: (_) => QrScanProvider(lookup),
          child: QrScannerPage(
            scanner: (context, onCode) => TextButton(
              key: const Key('fakeScan'),
              onPressed: () => onCode('qr-123'),
              child: const Text('scan'),
            ),
          ),
        ),
        mode: mode,
        observers: [recorder],
      );
      return recorder;
    }

    Future<void> scan(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('fakeScan')));
      await tester.pumpAndSettle();
    }

    testWidgets('a known code confirms and opens the prefilled add form',
        (tester) async {
      final recorder =
          await pumpScanner(tester, mode: themeModes.currentValue!);
      expect(find.text('Scan QR Code'), findsOneWidget);
      await scan(tester);
      expect(find.text('QR Code Successfully Scanned!'), findsOneWidget);
      final card = find.byKey(const Key('scanResultSoldier'));
      expect(find.descendant(of: card, matching: find.text('Lim Bah')),
          findsOneWidget);
      expect(find.descendant(of: card, matching: find.text('CPL')),
          findsOneWidget);
      expect(find.descendant(of: card, matching: find.text('Section IC')),
          findsOneWidget);
      await tester.tap(find.byKey(const Key('goToEditPage')));
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.addSoldier);
      expect(recorder.lastArguments, registration.profile);
    }, variant: themeModes);

    testWidgets('an unknown code shows the source error dialog',
        (tester) async {
      when(() => lookup(any())).thenAnswer((_) async => const Right(null));
      final recorder = await pumpScanner(tester);
      await scan(tester);
      expect(find.text('Invalid QR / No such key found!'), findsOneWidget);
      expect(find.byKey(const Key('goToEditPage')), findsNothing);
      expect(find.byKey(const Key('scanResultSoldier')), findsNothing);
      expect(recorder.names, isNot(contains(AppRoutes.addSoldier)));
    });

    testWidgets('a lookup failure shows a snackbar', (tester) async {
      when(() => lookup(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Offline')));
      await pumpScanner(tester);
      await scan(tester);
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('stays dark on a black page in either theme', (tester) async {
      await pumpScanner(tester, mode: themeModes.currentValue!);
      final context = tester.element(find.text('Scan QR Code'));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
          AppColors.black);
    }, variant: themeModes);

    testWidgets('the back arrow leaves the scanner', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            key: const Key('open'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => QrScanProvider(lookup),
                  child: QrScannerPage(
                    scanner: (context, onCode) => const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('open')));
      await tester.pumpAndSettle();
      expect(find.text('Scan QR Code'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Scan QR Code'), findsNothing);
    });
  });

  group('QrScannerOverlay', () {
    Rect rectOf(WidgetTester tester, String key) =>
        tester.getRect(find.byKey(Key(key)));

    double lineOffset(WidgetTester tester) =>
        rectOf(tester, 'scanLine').top - rectOf(tester, 'scanReticle').top;

    Future<void> pumpOverlay(WidgetTester tester,
            {ThemeMode mode = ThemeMode.dark}) =>
        tester.pumpThemed(const QrScannerOverlay(),
            mode: mode, wrapInScaffold: false);

    testWidgets('puts a 250 px reticle above the middle of the screen',
        (tester) async {
      await pumpOverlay(tester);
      final reticle = rectOf(tester, 'scanReticle');
      expect(reticle.size, const Size.square(250));
      expect(reticle.center.dx, closeTo(195, 0.01));
      expect(reticle.center.dy, closeTo(352, 0.5));
    });

    testWidgets('the scan line sweeps down and back inside the frame',
        (tester) async {
      await pumpOverlay(tester);
      expect(lineOffset(tester), closeTo(18, 0.01));
      await tester.pump(const Duration(milliseconds: 600));
      final partway = lineOffset(tester);
      expect(partway, greaterThan(18));
      expect(partway, lessThan(228));
      await tester.pump(const Duration(milliseconds: 1800));
      expect(lineOffset(tester), closeTo(228, 0.01));
      await tester.pump(const Duration(milliseconds: 2400));
      expect(lineOffset(tester), closeTo(18, 0.01));
      final line = rectOf(tester, 'scanLine');
      final reticle = rectOf(tester, 'scanReticle');
      expect(line.left - reticle.left, closeTo(14, 0.01));
      expect(reticle.right - line.right, closeTo(14, 0.01));
      expect(line.height, closeTo(2, 0.01));
    });

    testWidgets('the line takes the accent text colour', (tester) async {
      final mode = themeModes.currentValue!;
      await pumpOverlay(tester, mode: mode);
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      final line =
          tester.widget<DecoratedBox>(find.byKey(const Key('scanLine')));
      expect((line.decoration as BoxDecoration).color, palette.accentText);
    }, variant: themeModes);

    testWidgets('reduced motion holds the line still so the tree settles',
        (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await pumpOverlay(tester);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(lineOffset(tester), closeTo(123, 0.01));
    });

    testWidgets('leaving the page stops the sweep', (tester) async {
      await pumpOverlay(tester);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(const SizedBox());
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('ScannerFooter', () {
    testWidgets('lists the hint, an OR divider and a ghost gallery button',
        (tester) async {
      var picked = 0;
      await tester.pumpThemed(
        ScannerFooter(onGallery: () => picked++),
        mode: themeModes.currentValue!,
      );
      expect(
          find.text("Please scan the QR code on the soldier's profile by "
              'placing it within the frame to add their details.'),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const Key('scanOrDivider')),
              matching: find.text('OR')),
          findsOneWidget);
      final button =
          tester.widget<PrimaryButton>(find.byKey(const Key('scanGallery')));
      expect(button.label, 'SELECT FROM GALLERY');
      expect(button.style, PrimaryButtonStyle.ghost);
      await tester.tap(find.byKey(const Key('scanGallery')));
      expect(picked, 1);
    }, variant: themeModes);
  });
}

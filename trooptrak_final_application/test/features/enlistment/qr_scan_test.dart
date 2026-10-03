import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/entities/soldier_registration.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/repositories/men_repository.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/usecases/men_usecases.dart';
import 'package:trooptrak_final_application/features/enlistment/presentation/pages/qr_scanner_page.dart';
import 'package:trooptrak_final_application/features/enlistment/presentation/providers/qr_scan_provider.dart';

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
      expect(recorder.names, isNot(contains(AppRoutes.addSoldier)));
    });

    testWidgets('a lookup failure shows a snackbar', (tester) async {
      when(() => lookup(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Offline')));
      await pumpScanner(tester);
      await scan(tester);
      expect(find.text('Offline'), findsOneWidget);
    });
  });
}

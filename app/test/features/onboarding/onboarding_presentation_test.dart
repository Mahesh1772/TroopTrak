import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/onboarding/domain/entities/app_role.dart';
import 'package:trooptrak_final_application/features/onboarding/domain/usecases/role_usecases.dart';
import 'package:trooptrak_final_application/features/onboarding/presentation/pages/role_selection_page.dart';
import 'package:trooptrak_final_application/features/onboarding/presentation/pages/splash_page.dart';
import 'package:trooptrak_final_application/features/onboarding/presentation/providers/role_selection_provider.dart';

import '../../helpers/pump_app.dart';

class _MockGetRole extends Mock implements GetRole {}

class _MockSetRole extends Mock implements SetRole {}

void main() {
  late _MockSetRole setRole;

  setUpAll(() {
    registerFallbackValue(AppRole.soldier);
    registerFallbackValue(const NoParams());
  });
  setUp(() {
    setRole = _MockSetRole();
    when(() => setRole(any())).thenAnswer((_) async => const Right(unit));
  });

  group('RoleSelectionProvider', () {
    test('toggle is single-select and a second tap clears', () {
      final p = RoleSelectionProvider(setRole);
      p.toggle(AppRole.soldier);
      expect(p.selected, AppRole.soldier);
      p.toggle(AppRole.commander);
      expect(p.selected, AppRole.commander);
      p.toggle(AppRole.commander);
      expect(p.selected, isNull);
    });

    test('confirm without a selection does nothing', () async {
      expect(await RoleSelectionProvider(setRole).confirm(), isNull);
      verifyNever(() => setRole(any()));
    });

    test('confirm stores the role and returns its gate route', () async {
      final p = RoleSelectionProvider(setRole)..toggle(AppRole.commander);
      expect(await p.confirm(), AppRoutes.commanderGate);
      verify(() => setRole(AppRole.commander)).called(1);
    });

    test('confirm exposes a failure message', () async {
      when(() => setRole(any()))
          .thenAnswer((_) async => const Left(CacheFailure('disk')));
      final p = RoleSelectionProvider(setRole)..toggle(AppRole.soldier);
      expect(await p.confirm(), isNull);
      expect(p.error, 'disk');
      expect(p.saving, isFalse);
    });

    test('routeForRole maps every role (R18)', () {
      expect(routeForRole(null), AppRoutes.roleSelection);
      expect(routeForRole(AppRole.soldier), AppRoutes.soldierGate);
      expect(routeForRole(AppRole.commander), AppRoutes.commanderGate);
    });
  });

  group('SplashPage', () {
    for (final (role, route) in [
      (null, AppRoutes.roleSelection),
      (AppRole.soldier, AppRoutes.soldierGate),
      (AppRole.commander, AppRoutes.commanderGate),
    ]) {
      testWidgets('stored role $role opens $route', (tester) async {
        final getRole = _MockGetRole();
        when(() => getRole(any())).thenAnswer((_) async => Right(role));
        final recorder = RouteRecorder();

        await tester.pumpApp(
          const SplashPage(),
          providers: [Provider<GetRole>.value(value: getRole)],
          observers: [recorder],
        );
        await tester.pumpAndSettle();

        expect(recorder.names.last, route);
        expect(find.text('route:$route'), findsOneWidget);
      });
    }
  });

  group('RoleSelectionPage', () {
    Future<RouteRecorder> pump(WidgetTester tester, ThemeMode mode) async {
      final recorder = RouteRecorder();
      await tester.pumpApp(
        ChangeNotifierProvider(
          create: (_) => RoleSelectionProvider(setRole),
          child: const RoleSelectionPage(),
        ),
        mode: mode,
        observers: [recorder],
      );
      return recorder;
    }

    testWidgets('shows both roles and the guidance text', (tester) async {
      await pump(tester, themeModes.currentValue!);
      expect(find.text('Men'), findsOneWidget);
      expect(find.text('CFC and below'), findsOneWidget);
      expect(find.text('Commanders'), findsOneWidget);
      expect(find.text('3SG or higher'), findsOneWidget);
      expect(find.text('Please pick your role.'), findsOneWidget);
    }, variant: themeModes);

    testWidgets('arrow without a choice stays on the page', (tester) async {
      final recorder = await pump(tester, ThemeMode.dark);
      await tester.tap(find.byKey(const Key('role-confirm')));
      await tester.pumpAndSettle();
      expect(recorder.pushed.length, 1);
      verifyNever(() => setRole(any()));
    });

    testWidgets('choosing Men stores soldier and opens the soldier gate',
        (tester) async {
      final recorder = await pump(tester, ThemeMode.dark);
      await tester.tap(find.byKey(const Key('role-soldier')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('role-confirm')));
      await tester.pumpAndSettle();
      verify(() => setRole(AppRole.soldier)).called(1);
      expect(recorder.names.last, AppRoutes.soldierGate);
    });

    testWidgets('switching to Commanders stores commander', (tester) async {
      final recorder = await pump(tester, ThemeMode.light);
      await tester.tap(find.byKey(const Key('role-soldier')));
      await tester.tap(find.byKey(const Key('role-commander')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('role-confirm')));
      await tester.pumpAndSettle();
      verify(() => setRole(AppRole.commander)).called(1);
      expect(recorder.names.last, AppRoutes.commanderGate);
    });
  });
}

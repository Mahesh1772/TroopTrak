import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/core/widgets/brand_logo.dart';
import 'package:trooptrak_final_application/core/widgets/linear_loader.dart';
import 'package:trooptrak_final_application/core/widgets/primary_button.dart';
import 'package:trooptrak_final_application/core/widgets/rank_plate.dart';
import 'package:trooptrak_final_application/features/onboarding/domain/entities/app_role.dart';
import 'package:trooptrak_final_application/features/onboarding/domain/usecases/role_usecases.dart';
import 'package:trooptrak_final_application/features/onboarding/presentation/pages/role_selection_page.dart';
import 'package:trooptrak_final_application/features/onboarding/presentation/pages/splash_page.dart';
import 'package:trooptrak_final_application/features/onboarding/presentation/providers/role_selection_provider.dart';

import '../../helpers/pump_app.dart';

class _MockGetRole extends Mock implements GetRole {}

class _MockSetRole extends Mock implements SetRole {}

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

const _tagline = 'Command centre in your pocket';

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

    group('while the role is being read', () {
      late Completer<Either<Failure, AppRole?>> pending;

      Future<void> pumpSplash(WidgetTester tester, ThemeMode mode) {
        pending = Completer();
        final getRole = _MockGetRole();
        when(() => getRole(any())).thenAnswer((_) => pending.future);
        return tester.pumpApp(
          const SplashPage(),
          providers: [Provider<GetRole>.value(value: getRole)],
          mode: mode,
        );
      }

      testWidgets('shows the logo, the tagline and the loader', (tester) async {
        final mode = themeModes.currentValue!;
        await pumpSplash(tester, mode);

        expect(find.byType(BrandLogo), findsOneWidget);
        expect(tester.getSize(find.byType(BrandLogo)).width, 230);
        expect(find.text(_tagline), findsOneWidget);
        expect(tester.widget<Text>(find.text(_tagline)).style!.color,
            _paletteOf(mode).secondaryText);
        expect(find.byType(LinearLoader), findsOneWidget);
      }, variant: themeModes);

      testWidgets('stacks the logo, the tagline and the loader in the middle',
          (tester) async {
        await pumpSplash(tester, ThemeMode.dark);
        final logo = tester.getRect(find.byType(BrandLogo));
        final tagline = tester.getRect(find.text(_tagline));
        final loader = tester.getRect(find.byType(LinearLoader));

        expect(tagline.top, lessThan(logo.bottom));
        expect(loader.top - tagline.bottom, greaterThan(30));
        expect(logo.center.dx, closeTo(195, 0.01));
        expect(tagline.center.dx, closeTo(195, 0.01));
        expect(loader.center.dx, closeTo(195, 0.01));
        expect(loader.size, const Size(120, 3));
      });

      testWidgets('takes the page colour from the theme, not a fixed dark',
          (tester) async {
        final mode = themeModes.currentValue!;
        await pumpSplash(tester, mode);
        expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
            isNull);
        final theme = Theme.of(tester.element(find.byType(Scaffold)));
        expect(theme.scaffoldBackgroundColor, theme.colorScheme.surface);
        expect(theme.brightness,
            mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
      }, variant: themeModes);

      testWidgets('the loader keeps moving until the role arrives',
          (tester) async {
        await pumpSplash(tester, ThemeMode.dark);
        expect(tester.hasRunningAnimations, isTrue);
        pending.complete(const Right(null));
        await tester.pumpAndSettle();
        expect(find.text('route:${AppRoutes.roleSelection}'), findsOneWidget);
        expect(find.byType(LinearLoader), findsNothing);
      });
    });

    testWidgets('reduced motion lets the splash settle', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      final getRole = _MockGetRole();
      when(() => getRole(any()))
          .thenAnswer((_) => Completer<Either<Failure, AppRole?>>().future);
      await tester.pumpApp(
        const SplashPage(),
        providers: [Provider<GetRole>.value(value: getRole)],
      );
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.byType(LinearLoader), findsOneWidget);
    });
  });

  group('LinearLoader', () {
    Future<void> pumpLoader(WidgetTester tester, {ThemeMode? mode}) =>
        tester.pumpThemed(
          const Center(child: LinearLoader()),
          mode: mode ?? ThemeMode.dark,
        );

    double fillLeft(WidgetTester tester) =>
        tester.getRect(find.byKey(const Key('loaderFill'))).left -
        tester.getRect(find.byType(LinearLoader)).left;

    testWidgets('is a 120 by 3 track with a 40 percent accent segment',
        (tester) async {
      final mode = themeModes.currentValue!;
      await pumpLoader(tester, mode: mode);
      expect(tester.getSize(find.byType(LinearLoader)), const Size(120, 3));
      final fill =
          tester.widget<DecoratedBox>(find.byKey(const Key('loaderFill')));
      expect((fill.decoration as BoxDecoration).color, _paletteOf(mode).accent);
      expect(tester.getSize(find.byKey(const Key('loaderFill'))).width,
          closeTo(48, 0.01));
      final track = tester.widget<ColoredBox>(find.descendant(
          of: find.byType(LinearLoader), matching: find.byType(ColoredBox)));
      expect(track.color, _paletteOf(mode).tickOff);
    }, variant: themeModes);

    testWidgets('the segment sweeps from before the track to past it',
        (tester) async {
      await pumpLoader(tester);
      expect(fillLeft(tester), closeTo(-48, 0.5));
      await tester.pump(const Duration(milliseconds: 400));
      final partway = fillLeft(tester);
      expect(partway, greaterThan(-48));
      await tester.pump(const Duration(milliseconds: 1000));
      expect(fillLeft(tester), lessThan(partway));
    });

    testWidgets('reduced motion rests the segment in the middle',
        (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await pumpLoader(tester);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(fillLeft(tester), closeTo(36, 0.5));
    });

    testWidgets('leaving the page stops the sweep', (tester) async {
      await pumpLoader(tester);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(const SizedBox());
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('BrandLogo', () {
    testWidgets('is inverted to white on dark and plain black on light',
        (tester) async {
      final mode = themeModes.currentValue!;
      await tester.pumpThemed(const BrandLogo(width: 100), mode: mode);
      expect(find.byType(ColorFiltered),
          mode == ThemeMode.dark ? findsOneWidget : findsNothing);
      expect(tester.getSize(find.byType(BrandLogo)).width, 100);
      expect(find.bySemanticsLabel('TroopTrak'), findsOneWidget);
    }, variant: themeModes);
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

    Finder inCard(String key, String child) => find.descendant(
        of: find.byKey(Key(key)), matching: find.byKey(Key(child)));

    Border borderOf(WidgetTester tester, String key) {
      final body =
          tester.widget<AnimatedContainer>(inCard(key, 'roleCardBody'));
      return (body.foregroundDecoration! as BoxDecoration).border! as Border;
    }

    testWidgets('shows both roles and the guidance text', (tester) async {
      await pump(tester, themeModes.currentValue!);
      expect(find.text('Men'), findsOneWidget);
      expect(find.text('CFC and below'), findsOneWidget);
      expect(find.text('Commanders'), findsOneWidget);
      expect(find.text('3SG or higher'), findsOneWidget);
      expect(find.text('Please pick your role.'), findsOneWidget);
      expect(
          find.text('If you are rank 3SG or higher, select commanders. '
              'If your rank is CFC or lower, select men.'),
          findsOneWidget);
      expect(find.byType(BrandLogo), findsOneWidget);
      expect(tester.getSize(find.byType(BrandLogo)).width, 120);
    }, variant: themeModes);

    testWidgets('each card carries a large insignia plate for its rank',
        (tester) async {
      await pump(tester, themeModes.currentValue!);
      final soldier = tester.widget<RankPlate>(find.descendant(
          of: find.byKey(const Key('role-soldier')),
          matching: find.byType(RankPlate)));
      final commander = tester.widget<RankPlate>(find.descendant(
          of: find.byKey(const Key('role-commander')),
          matching: find.byType(RankPlate)));
      expect(soldier.rank, 'CFC');
      expect(commander.rank, '3SG');
      expect(soldier.size, RankPlate.lg);
      expect(commander.size, RankPlate.lg);
      expect(
          tester.getSize(find.byType(RankPlate).first), const Size.square(64));
    }, variant: themeModes);

    testWidgets('the cards are full-width rows above CONTINUE', (tester) async {
      await pump(tester, ThemeMode.dark);
      final soldier = tester.getRect(find.byKey(const Key('role-soldier')));
      final commander = tester.getRect(find.byKey(const Key('role-commander')));
      final confirm = tester.getRect(find.byKey(const Key('role-confirm')));

      expect(soldier.left, 24);
      expect(soldier.width, 342);
      expect(commander.left, 24);
      expect(commander.top - soldier.bottom, 12);
      expect(confirm.left, 24);
      expect(confirm.width, 342);
      expect(confirm.height, 50);
      expect(confirm.top, greaterThan(commander.bottom));
      expect(confirm.bottom, greaterThan(700));
    });

    testWidgets('CONTINUE is a primary button with a trailing arrow',
        (tester) async {
      await pump(tester, ThemeMode.dark);
      final button =
          tester.widget<PrimaryButton>(find.byKey(const Key('role-confirm')));
      expect(button.label, 'CONTINUE');
      expect(button.style, PrimaryButtonStyle.primary);
      expect(button.onPressed, isNotNull);
      final arrow = find.descendant(
          of: find.byKey(const Key('role-confirm')),
          matching: find.byIcon(Icons.arrow_forward_rounded));
      expect(arrow, findsOneWidget);
      expect(tester.getTopLeft(arrow).dx,
          greaterThan(tester.getTopRight(find.text('CONTINUE')).dx));
    });

    testWidgets('no card is selected until one is tapped', (tester) async {
      final mode = themeModes.currentValue!;
      await pump(tester, mode);
      for (final key in ['role-soldier', 'role-commander']) {
        final side = borderOf(tester, key).top;
        expect(side.color, _paletteOf(mode).line);
        expect(side.width, 1.5);
        expect(inCard(key, 'roleRadioDot'), findsNothing);
      }
    }, variant: themeModes);

    testWidgets('the selected card gets the accent border and a filled radio',
        (tester) async {
      final mode = themeModes.currentValue!;
      await pump(tester, mode);
      final palette = _paletteOf(mode);
      await tester.tap(find.byKey(const Key('role-commander')));
      await tester.pump();

      final chosen = borderOf(tester, 'role-commander').top;
      expect(chosen.color, palette.accent);
      expect(chosen.width, 2);
      expect(inCard('role-commander', 'roleRadioDot'), findsOneWidget);
      expect(tester.getSize(inCard('role-commander', 'roleRadioDot')),
          const Size.square(12));
      expect(tester.getSize(inCard('role-commander', 'roleRadio')),
          const Size.square(24));

      expect(borderOf(tester, 'role-soldier').top.color, palette.line);
      expect(inCard('role-soldier', 'roleRadioDot'), findsNothing);
    }, variant: themeModes);

    testWidgets('the selection moves between cards and a second tap clears it',
        (tester) async {
      await pump(tester, ThemeMode.dark);

      await tester.tap(find.byKey(const Key('role-soldier')));
      await tester.pump();
      expect(inCard('role-soldier', 'roleRadioDot'), findsOneWidget);
      expect(inCard('role-commander', 'roleRadioDot'), findsNothing);

      await tester.tap(find.byKey(const Key('role-commander')));
      await tester.pump();
      expect(inCard('role-soldier', 'roleRadioDot'), findsNothing);
      expect(inCard('role-commander', 'roleRadioDot'), findsOneWidget);

      await tester.tap(find.byKey(const Key('role-commander')));
      await tester.pump();
      expect(inCard('role-commander', 'roleRadioDot'), findsNothing);
    });

    testWidgets('CONTINUE is disabled while the role is being saved',
        (tester) async {
      final saving = Completer<Either<Failure, Unit>>();
      when(() => setRole(any())).thenAnswer((_) => saving.future);
      await pump(tester, ThemeMode.dark);
      await tester.tap(find.byKey(const Key('role-soldier')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('role-confirm')));
      await tester.pump();
      expect(
          tester
              .widget<PrimaryButton>(find.byKey(const Key('role-confirm')))
              .onPressed,
          isNull);
      saving.complete(const Right(unit));
      await tester.pumpAndSettle();
    });

    testWidgets('a failed save stays on the page and shows the message',
        (tester) async {
      when(() => setRole(any()))
          .thenAnswer((_) async => const Left(CacheFailure('disk')));
      final recorder = await pump(tester, ThemeMode.dark);
      await tester.tap(find.byKey(const Key('role-soldier')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('role-confirm')));
      await tester.pump();
      await tester.pump();
      expect(find.text('disk'), findsOneWidget);
      expect(recorder.pushed.length, 1);
    });

    testWidgets('CONTINUE without a choice stays on the page', (tester) async {
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

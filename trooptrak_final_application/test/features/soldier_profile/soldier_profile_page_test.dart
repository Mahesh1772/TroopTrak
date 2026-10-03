import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/pages/soldier_profile_page.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/profile_capabilities.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/providers/soldier_profile_provider.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';

import '../../helpers/builders.dart';
import '../../helpers/pump_app.dart';

void main() {
  late StreamController<Either<Failure, Soldier>> soldier;

  setUp(() => soldier = StreamController<Either<Failure, Soldier>>());
  tearDown(() => soldier.close());

  Future<void> pumpProfile(WidgetTester tester,
          {ThemeMode mode = ThemeMode.dark, List<Widget> actions = const []}) =>
      tester.pumpApp(
        ChangeNotifierProvider(
          create: (_) => SoldierProfileProvider(soldier.stream),
          child: SoldierProfilePage(
            capabilities: ProfileCapabilities.commanderViewingSoldier,
            headerActions: actions,
          ),
        ),
        mode: mode,
      );

  testWidgets('shows loading until the soldier arrives', (tester) async {
    await pumpProfile(tester);
    expect(find.byType(LoadingView), findsOneWidget);
  });

  testWidgets('header shows name, appointment, unit and rank insignia',
      (tester) async {
    await pumpProfile(tester, mode: themeModes.currentValue!);
    soldier.add(Right(buildSoldier(rank: 'CPL', company: 'Alpha')));
    await tester.pumpAndSettle();

    expect(find.text('TAN AH KOW'), findsOneWidget);
    expect(find.text('Section IC'), findsOneWidget);
    expect(find.text('ALPHA COMPANY'), findsOneWidget);
    expect(find.text('Platoon 1, Section 2'), findsOneWidget);
    final insignia = tester.widget<Image>(find.byWidgetPredicate((w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName == 'lib/assets/army-ranks/cpl.png'));
    expect(insignia.color, Colors.white);
  }, variant: themeModes);

  testWidgets('officer insignia keeps its own colours', (tester) async {
    await pumpProfile(tester);
    soldier.add(Right(buildSoldier(rank: '2LT')));
    await tester.pumpAndSettle();
    final insignia = tester.widget<Image>(find.byWidgetPredicate((w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName == 'lib/assets/army-ranks/2lt.png'));
    expect(insignia.color, isNull);
  });

  testWidgets('three tabs switch content', (tester) async {
    await pumpProfile(tester);
    soldier.add(Right(buildSoldier()));
    await tester.pumpAndSettle();

    for (final label in ['BASIC INFO', 'STATUSES', 'ATTENDANCE']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Basic info'), findsOneWidget);
    await tester.tap(find.text('STATUSES'));
    await tester.pumpAndSettle();
    expect(find.text('Statuses'), findsOneWidget);
    await tester.tap(find.text('ATTENDANCE'));
    await tester.pumpAndSettle();
    expect(find.text('Attendance'), findsOneWidget);
  });

  testWidgets('header actions render under the unit lines', (tester) async {
    await pumpProfile(tester, actions: [const Text('SIGN OUT')]);
    soldier.add(Right(buildSoldier()));
    await tester.pumpAndSettle();
    expect(find.text('SIGN OUT'), findsOneWidget);
  });

  testWidgets('a missing soldier shows the error', (tester) async {
    await pumpProfile(tester);
    soldier.add(const Left(NotFoundFailure('Soldier X was not found.')));
    await tester.pumpAndSettle();
    expect(find.text('Soldier X was not found.'), findsOneWidget);
  });

  testWidgets('back pops the page', (tester) async {
    await tester.pumpApp(Builder(
      builder: (context) => TextButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => SoldierProfileProvider(soldier.stream),
            child: const SoldierProfilePage(
                capabilities: ProfileCapabilities.commanderViewingSoldier),
          ),
        )),
        child: const Text('open'),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump();
    soldier.add(Right(buildSoldier()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profileBack')));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });
}

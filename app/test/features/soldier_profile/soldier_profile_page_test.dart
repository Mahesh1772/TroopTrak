import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/features/attendance/domain/entities/attendance_record.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/pages/soldier_profile_page.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/profile_actions.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/profile_capabilities.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/providers/soldier_profile_provider.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/usecases/status_usecases.dart';

import '../../helpers/builders.dart';
import '../../helpers/pump_app.dart';

class _MockWatchStatuses extends Mock implements WatchSoldierStatuses {}

class _MockDeleteStatus extends Mock implements DeleteStatus {}

class _MockWatchAttendance extends Mock implements WatchAttendance {}

class _MockDeleteAttendance extends Mock implements DeleteAttendance {}

void main() {
  late StreamController<Either<Failure, Soldier>> soldier;
  final watchStatuses = _MockWatchStatuses();
  final watchAttendance = _MockWatchAttendance();
  setUpAll(() {
    when(() => watchStatuses(any())).thenAnswer(
        (_) => Stream.value(const Right<Failure, List<Status>>([])));
    when(() => watchAttendance(any())).thenAnswer((_) => Stream.value(
        Right<Failure, List<AttendanceRecord>>([buildAttendance()])));
  });
  final tabProviders = [
    Provider<WatchSoldierStatuses>.value(value: watchStatuses),
    Provider<DeleteStatus>.value(value: _MockDeleteStatus()),
    Provider<WatchAttendance>.value(value: watchAttendance),
    Provider<DeleteAttendance>.value(value: _MockDeleteAttendance()),
  ];

  late List<String> calls;
  late Either<Failure, Unit> deleteResult;
  late ProfileActions profileActions;

  setUp(() {
    soldier = StreamController<Either<Failure, Soldier>>();
    calls = [];
    deleteResult = const Right(unit);
    profileActions = ProfileActions(
      edit: (_, s) => calls.add('edit ${s.id}'),
      delete: (s) async {
        calls.add('delete ${s.id}');
        return deleteResult;
      },
      afterDelete: (_) => calls.add('afterDelete'),
    );
  });
  tearDown(() => soldier.close());

  Future<void> pumpProfile(WidgetTester tester,
          {ThemeMode mode = ThemeMode.dark,
          List<Widget> actions = const [],
          ProfileCapabilities capabilities =
              ProfileCapabilities.commanderViewingSoldier}) =>
      tester.pumpApp(
        ChangeNotifierProvider(
          create: (_) => SoldierProfileProvider(soldier.stream),
          child: SoldierProfilePage(
            capabilities: capabilities,
            actions: profileActions,
            headerActions: actions,
          ),
        ),
        mode: mode,
        providers: tabProviders,
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
    expect(find.text('Date Of Birth'), findsOneWidget);
    await tester.tap(find.text('STATUSES'));
    await tester.pumpAndSettle();
    expect(find.text('Active Statuses'), findsOneWidget);
    await tester.tap(find.text('ATTENDANCE'));
    await tester.pumpAndSettle();
    expect(find.text('Book In / Book Out'), findsOneWidget);
    expect(find.text('Wed 5 Jul 2023 08:00:00'), findsOneWidget);
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
    await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => SoldierProfileProvider(soldier.stream),
                child: SoldierProfilePage(
                    capabilities: ProfileCapabilities.commanderViewingSoldier,
                    actions: profileActions),
              ),
            )),
            child: const Text('open'),
          ),
        ),
        providers: tabProviders);
    await tester.tap(find.text('open'));
    await tester.pump();
    soldier.add(Right(buildSoldier()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profileBack')));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });

  group('basic info tab', () {
    Future<void> openWith(WidgetTester tester, Soldier s,
        {ProfileCapabilities capabilities =
            ProfileCapabilities.commanderViewingSoldier}) async {
      await pumpProfile(tester, capabilities: capabilities);
      soldier.add(Right(s));
      await tester.pumpAndSettle();
    }

    Future<void> tapDelete(WidgetTester tester) async {
      final button = find.byKey(const Key('deleteSoldier'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets('shows the five source rows', (tester) async {
      await openWith(
          tester,
          buildSoldier(
            dob: DateTime(2000, 7, 5),
            rationType: 'sd nm',
            bloodGroup: 'AB+',
            enlistment: DateTime(2023, 1, 1),
            ord: DateTime(2025, 1, 1),
          ));
      for (final (title, content) in [
        ('Date Of Birth', '5 JUL 2000'),
        ('Ration Type:', 'SD NM'),
        ('Blood Type:', 'AB+'),
        ('Enlistment Date:', '1 JAN 2023'),
        ('ORD:', '1 JAN 2025'),
      ]) {
        expect(find.text(title), findsOneWidget);
        expect(find.text(content), findsOneWidget);
      }
    });

    testWidgets('edit hands the soldier to the edit action', (tester) async {
      await openWith(tester, buildSoldier());
      final button = find.byKey(const Key('editSoldier'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      expect(calls, ['edit Tan Ah Kow']);
    });

    testWidgets('confirmed delete runs the cascade once, then leaves',
        (tester) async {
      await openWith(tester, buildSoldier());
      await tapDelete(tester);
      expect(find.text('Delete Tan Ah Kow?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(calls, ['delete Tan Ah Kow', 'afterDelete']);
      await tester.pump();
      expect(find.text('Tan Ah Kow deleted'), findsOneWidget);
    });

    testWidgets('cancelling the dialog does nothing', (tester) async {
      await openWith(tester, buildSoldier());
      await tapDelete(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
    });

    testWidgets('a failed delete shows the error and stays', (tester) async {
      deleteResult = const Left(ServerFailure('Could not delete.'));
      await openWith(tester, buildSoldier());
      await tapDelete(tester);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(calls, ['delete Tan Ah Kow']);
      expect(find.text('Could not delete.'), findsOneWidget);
    });

    testWidgets('without edit or delete rights the buttons are hidden',
        (tester) async {
      await openWith(tester, buildSoldier(),
          capabilities: const ProfileCapabilities());
      expect(find.byKey(const Key('editSoldier')), findsNothing);
      expect(find.byKey(const Key('deleteSoldier')), findsNothing);
    });
  });
}

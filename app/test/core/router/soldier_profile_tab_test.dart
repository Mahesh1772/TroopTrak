import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/router/soldier_routes.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/attendance/domain/entities/attendance_record.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/auth_usecases.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/update_soldier_profile.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/usecases/men_usecases.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/usecases/status_usecases.dart';

import '../../helpers/builders.dart';
import '../../helpers/pump_app.dart';

class _MockWatchAuth extends Mock implements WatchAuthState {}

class _MockWatchOwn extends Mock implements WatchOwnRegistration {}

class _MockWatchStatuses extends Mock implements WatchSoldierStatuses {}

class _MockDeleteStatus extends Mock implements DeleteStatus {}

class _MockWatchAttendance extends Mock implements WatchAttendance {}

class _MockDeleteAttendance extends Mock implements DeleteAttendance {}

class _MockSignOut extends Mock implements SignOut {}

class _MockUpdateProfile extends Mock implements UpdateSoldierProfile {}

void main() {
  final me = buildSoldier(name: 'Lim Bah', id: 'Lim Bah', rank: 'PTE');
  final active = buildStatus(
      id: 'a',
      soldierId: me.id,
      start: DateTime(2023, 7, 1),
      end: DateTime(2023, 7, 10));
  final past = buildStatus(
      id: 'p',
      soldierId: me.id,
      start: DateTime(2023, 6, 1),
      end: DateTime(2023, 6, 4));
  final record = buildAttendance(id: 'r1', soldierId: me.id);
  late _MockWatchOwn watchOwn;
  late _MockSignOut signOut;
  late _MockUpdateProfile updateProfile;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(buildSoldier());
  });

  setUp(() {
    watchOwn = _MockWatchOwn();
    signOut = _MockSignOut();
    updateProfile = _MockUpdateProfile();
    when(() => watchOwn(any()))
        .thenAnswer((_) => Stream.value(Right<Failure, Soldier>(me)));
    when(() => signOut(any())).thenAnswer((_) async => const Right(unit));
    when(() => updateProfile(any())).thenAnswer((_) async => const Right(unit));
  });

  Future<RouteRecorder> pumpTab(WidgetTester tester,
      {ThemeMode mode = ThemeMode.dark}) async {
    final watchAuth = _MockWatchAuth();
    when(() => watchAuth.current)
        .thenReturn(const AuthUser(uid: 'u1', displayName: 'Lim Bah'));
    final statuses = _MockWatchStatuses();
    when(() => statuses(any())).thenAnswer(
        (_) => Stream.value(Right<Failure, List<Status>>([active, past])));
    final attendance = _MockWatchAttendance();
    when(() => attendance(any())).thenAnswer(
        (_) => Stream.value(Right<Failure, List<AttendanceRecord>>([record])));
    final recorder = RouteRecorder();
    await tester.pumpApp(
      const Builder(builder: soldierProfileTab),
      mode: mode,
      observers: [recorder],
      providers: [
        Provider<WatchAuthState>.value(value: watchAuth),
        Provider<WatchOwnRegistration>.value(value: watchOwn),
        Provider<WatchSoldierStatuses>.value(value: statuses),
        Provider<DeleteStatus>.value(value: _MockDeleteStatus()),
        Provider<WatchAttendance>.value(value: attendance),
        Provider<DeleteAttendance>.value(value: _MockDeleteAttendance()),
        Provider<SignOut>.value(value: signOut),
        Provider<UpdateSoldierProfile>.value(value: updateProfile),
      ],
    );
    await tester.pumpAndSettle();
    return recorder;
  }

  testWidgets(
      'shows the signed-in soldier\'s Men profile with QR, sign-out icon, '
      'edit and no delete', (tester) async {
    await pumpTab(tester, mode: themeModes.currentValue!);
    verify(() => watchOwn('u1')).called(1);
    expect(find.text('LIM BAH'), findsOneWidget);
    expect(find.byKey(const Key('profileBack')), findsNothing);
    expect(find.byKey(const Key('signOutIcon')), findsOneWidget);
    expect(find.byKey(const Key('signOutButton')), findsNothing);
    expect(find.byKey(const Key('themeToggle')), findsNothing);
    expect(find.text('SHOW QR CODE'), findsOneWidget);
    expect(find.byKey(const Key('editSoldier')), findsOneWidget);
    expect(find.byKey(const Key('deleteSoldier')), findsNothing);
  }, variant: themeModes);

  testWidgets('statuses and attendance tabs are read-only', (tester) async {
    await pumpTab(tester);
    await tester.tap(find.text('STATUSES'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('activeStatus-a')), findsOneWidget);
    expect(find.byKey(const Key('addStatus')), findsNothing);
    expect(find.byKey(const Key('deleteStatus-a')), findsNothing);
    expect(find.text('Past Statuses'), findsOneWidget);
    expect(find.text('1 Jun 2023 - 4 Jun 2023', skipOffstage: false),
        findsOneWidget);
    expect(find.byType(Slidable), findsNothing);

    await tester.tap(find.text('ATTENDANCE'));
    await tester.pumpAndSettle();
    expect(find.text('BOOK IN'), findsOneWidget);
    expect(find.byType(Slidable), findsNothing);
  });

  testWidgets('the sign-out icon signs out to role selection (D4)',
      (tester) async {
    final recorder = await pumpTab(tester);
    await tester.tap(find.byKey(const Key('signOutIcon')));
    await tester.pumpAndSettle();
    verify(() => signOut(const NoParams())).called(1);
    expect(recorder.names.last, AppRoutes.roleSelection);
  });

  testWidgets('SHOW QR CODE opens the QR route', (tester) async {
    final recorder = await pumpTab(tester);
    await tester.tap(find.text('SHOW QR CODE'));
    await tester.pumpAndSettle();
    expect(recorder.names.last, AppRoutes.generateQr);
  });

  testWidgets('edit opens the own-edit route with the profile', (tester) async {
    final recorder = await pumpTab(tester);
    final edit = find.byKey(const Key('editSoldier'));
    await tester.ensureVisible(edit);
    await tester.pumpAndSettle();
    await tester.tap(edit);
    await tester.pumpAndSettle();
    expect(recorder.names.last, AppRoutes.editOwnProfile);
    expect(recorder.lastArguments, me);
  });

  group('own edit form', () {
    Future<void> pumpForm(WidgetTester tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (context) =>
                    soldierRoutes[AppRoutes.editOwnProfile]!(context, me),
              )),
              child: const Text('open'),
            ),
          ),
        ),
        providers: [
          Provider<UpdateSoldierProfile>.value(value: updateProfile),
        ],
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('offers the soldier rank list', (tester) async {
      await pumpForm(tester);
      final field = find.byKey(const Key('profile-rank'));
      await tester.ensureVisible(field);
      await tester.pumpAndSettle();
      await tester.tap(field);
      await tester.pumpAndSettle();
      expect(find.text('REC'), findsWidgets);
      expect(find.text('OCT'), findsWidgets);
      expect(find.text('3SG'), findsNothing);
    });

    testWidgets('saves through UpdateSoldierProfile', (tester) async {
      await pumpForm(tester);
      await tester.enterText(
          find.byKey(const Key('profile-name')), 'Lim Ah Bah');
      final save = find.byKey(const Key('saveSoldier'));
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      verify(() => updateProfile(me.copyWith(name: 'Lim Ah Bah'))).called(1);
      expect(find.text('open'), findsOneWidget);
    });
  });
}

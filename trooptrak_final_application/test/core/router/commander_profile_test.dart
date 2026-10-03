import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/router/commander_routes.dart';
import 'package:trooptrak_final_application/core/theme/theme_manager.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/attendance/domain/entities/attendance_record.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/auth_usecases.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/delete_commander_account.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/usecases/soldier_usecases.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/usecases/status_usecases.dart';

import '../../helpers/builders.dart';
import '../../helpers/pump_app.dart';

class _MockWatchAuth extends Mock implements WatchAuthState {}

class _MockWatchSoldier extends Mock implements WatchSoldier {}

class _MockWatchStatuses extends Mock implements WatchSoldierStatuses {}

class _MockWatchAttendance extends Mock implements WatchAttendance {}

class _MockSignOut extends Mock implements SignOut {}

class _MockDeleteAccount extends Mock implements DeleteCommanderAccount {}

void main() {
  final me = buildSoldier(name: 'Cmd Lim', rank: 'CPT');
  late _MockSignOut signOut;
  late _MockDeleteAccount deleteAccount;
  late _MockWatchSoldier watchSoldier;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    signOut = _MockSignOut();
    deleteAccount = _MockDeleteAccount();
    watchSoldier = _MockWatchSoldier();
    when(() => signOut(any())).thenAnswer((_) async => const Right(unit));
    when(() => deleteAccount(any())).thenAnswer((_) async => const Right(unit));
    when(() => watchSoldier(any()))
        .thenAnswer((_) => Stream.value(Right<Failure, Soldier>(me)));
  });

  Future<RouteRecorder> pumpProfile(WidgetTester tester,
      {ThemeMode mode = ThemeMode.dark}) async {
    final watchAuth = _MockWatchAuth();
    when(() => watchAuth.current)
        .thenReturn(const AuthUser(uid: 'c1', displayName: 'Cmd Lim'));
    final statuses = _MockWatchStatuses();
    when(() => statuses(any())).thenAnswer(
        (_) => Stream.value(const Right<Failure, List<Status>>([])));
    final attendance = _MockWatchAttendance();
    when(() => attendance(any())).thenAnswer(
        (_) => Stream.value(const Right<Failure, List<AttendanceRecord>>([])));
    final recorder = RouteRecorder();
    await tester.pumpApp(
      Builder(builder: (context) => commanderProfile(context, null)),
      mode: mode,
      observers: [recorder],
      providers: [
        Provider<WatchAuthState>.value(value: watchAuth),
        Provider<WatchSoldier>.value(value: watchSoldier),
        Provider<WatchSoldierStatuses>.value(value: statuses),
        Provider<WatchAttendance>.value(value: attendance),
        Provider<SignOut>.value(value: signOut),
        Provider<DeleteCommanderAccount>.value(value: deleteAccount),
      ],
    );
    await tester.pumpAndSettle();
    return recorder;
  }

  testWidgets(
      'opens the signed-in commander\'s own Users doc with sign out '
      'and theme toggle', (tester) async {
    await pumpProfile(tester, mode: themeModes.currentValue!);
    verify(() => watchSoldier('Cmd Lim')).called(1);
    expect(find.text('CMD LIM'), findsOneWidget);
    expect(find.byKey(const Key('signOutButton')), findsOneWidget);
    expect(find.byKey(const Key('themeToggle')), findsOneWidget);
  }, variant: themeModes);

  testWidgets('sign out clears everything and returns to role selection (D4)',
      (tester) async {
    final recorder = await pumpProfile(tester);
    await tester.tap(find.byKey(const Key('signOutButton')));
    await tester.pumpAndSettle();
    verify(() => signOut(const NoParams())).called(1);
    expect(recorder.names.last, AppRoutes.roleSelection);
  });

  testWidgets('the theme toggle switches the app theme', (tester) async {
    await pumpProfile(tester);
    final manager = tester
        .element(find.byKey(const Key('themeToggle')))
        .read<ThemeManager>();
    expect(manager.isDark, isTrue);
    final toggle = find.byKey(const Key('themeToggle'));
    await tester.tapAt(tester.getTopLeft(toggle) + const Offset(15, 15));
    await tester.pumpAndSettle();
    expect(manager.isDark, isFalse);
  });

  testWidgets('edit opens the soldier form in edit mode with own details',
      (tester) async {
    final recorder = await pumpProfile(tester);
    final edit = find.byKey(const Key('editSoldier'));
    await tester.ensureVisible(edit);
    await tester.pumpAndSettle();
    await tester.tap(edit);
    await tester.pumpAndSettle();
    expect(recorder.names.last, AppRoutes.editSoldier);
    expect(recorder.lastArguments, me);
  });

  testWidgets('confirmed delete removes the account and goes to sign-in (K19)',
      (tester) async {
    final recorder = await pumpProfile(tester);
    final delete = find.byKey(const Key('deleteSoldier'));
    await tester.ensureVisible(delete);
    await tester.pumpAndSettle();
    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(
        find.text('This deletes your account with all your statuses and '
            'attendance records.'),
        findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    verify(() => deleteAccount('Cmd Lim')).called(1);
    expect(recorder.names.last, AppRoutes.commanderGate);
  });

  testWidgets('a stale sign-in shows the re-sign-in message', (tester) async {
    when(() => deleteAccount(any()))
        .thenAnswer((_) async => const Left(AuthFailure(reSignInMessage)));
    final recorder = await pumpProfile(tester);
    final delete = find.byKey(const Key('deleteSoldier'));
    await tester.ensureVisible(delete);
    await tester.pumpAndSettle();
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text(reSignInMessage), findsOneWidget);
    expect(recorder.names, isNot(contains(AppRoutes.commanderGate)));
  });
}

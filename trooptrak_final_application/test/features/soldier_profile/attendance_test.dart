import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/features/attendance/domain/entities/attendance_record.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/pages/edit_attendance_page.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/providers/attendance_provider.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/widgets/attendance_tab.dart';

import '../../helpers/builders.dart';
import '../../helpers/pump_app.dart';

class _MockWatch extends Mock implements WatchAttendance {}

class _MockDelete extends Mock implements DeleteAttendance {}

class _MockUpdate extends Mock implements UpdateAttendance {}

void main() {
  late _MockWatch watch;
  late _MockDelete delete;
  late _MockUpdate update;
  late StreamController<Either<Failure, List<AttendanceRecord>>> records;

  final newer = buildAttendance(timestamp: DateTime(2023, 7, 5, 8, 15));
  final older =
      buildAttendance(isInsideCamp: false, timestamp: DateTime(2023, 7, 4, 18));

  setUpAll(() => registerFallbackValue(buildAttendance()));

  setUp(() {
    watch = _MockWatch();
    delete = _MockDelete();
    update = _MockUpdate();
    records = StreamController<Either<Failure, List<AttendanceRecord>>>();
    when(() => watch(any())).thenAnswer((_) => records.stream);
    when(() => delete(any())).thenAnswer((_) async => const Right(unit));
    when(() => update(any())).thenAnswer((_) async => const Right(unit));
  });

  tearDown(() => unawaited(records.close()));

  AttendanceProvider provider() =>
      AttendanceProvider(watch: watch, delete: delete, soldierId: 'Tan Ah Kow');

  test('provider follows the use case stream and reports delete failures',
      () async {
    final p = provider();
    records.add(Right([newer, older]));
    await Future<void>.delayed(Duration.zero);
    expect(p.state.dataOrNull, [newer, older]);
    verify(() => watch('Tan Ah Kow')).called(1);

    expect(await p.delete(older), isNull);
    when(() => delete(any()))
        .thenAnswer((_) async => const Left(ServerFailure('down')));
    expect(await p.delete(older), 'down');
    p.dispose();
  });

  Future<void> pumpTab(WidgetTester tester,
      {bool canManage = true, ThemeMode mode = ThemeMode.dark}) async {
    await tester.pumpApp(
      Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => provider(),
          child: AttendanceTab(canManage: canManage),
        ),
      ),
      mode: mode,
      providers: [Provider<UpdateAttendance>.value(value: update)],
    );
    records.add(Right([newer, older]));
    await tester.pumpAndSettle();
  }

  testWidgets('tiles keep the use case order with in/out labels and colours',
      (tester) async {
    await pumpTab(tester, mode: themeModes.currentValue!);
    final first = tester.getTopLeft(find.text('Wed 5 Jul 2023 08:15:00')).dy;
    final second = tester.getTopLeft(find.text('Tue 4 Jul 2023 18:00:00')).dy;
    expect(first, lessThan(second));
    expect(find.text('BOOK IN'), findsOneWidget);
    expect(find.text('BOOKOUT'), findsOneWidget);
    final colours = tester
        .widgetList<Container>(find.descendant(
            of: find.byType(AttendanceTile), matching: find.byType(Container)))
        .map((c) => (c.decoration as BoxDecoration?)?.color)
        .whereType<Color>()
        .toList();
    expect(colours, [AppColors.bookIn, AppColors.danger]);
  }, variant: themeModes);

  testWidgets('empty list shows the empty state', (tester) async {
    await tester.pumpApp(Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => provider(),
        child: const AttendanceTab(canManage: true),
      ),
    ));
    records.add(const Right([]));
    await tester.pumpAndSettle();
    expect(find.text('No attendance records'), findsOneWidget);
  });

  testWidgets('slide to delete removes the record', (tester) async {
    await pumpTab(tester);
    await tester.drag(
        find.byKey(Key('attendance-${older.id}')), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('deleteAttendance-${older.id}')));
    await tester.pumpAndSettle();
    verify(() => delete(older)).called(1);
    expect(find.text('Attendance record deleted'), findsOneWidget);
  });

  testWidgets('a failed delete shows the error snackbar', (tester) async {
    when(() => delete(any()))
        .thenAnswer((_) async => const Left(ServerFailure('No network')));
    await pumpTab(tester);
    await tester.drag(
        find.byKey(Key('attendance-${older.id}')), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('deleteAttendance-${older.id}')));
    await tester.pumpAndSettle();
    expect(find.text('No network'), findsOneWidget);
  });

  testWidgets('a failed attendance stream shows the error', (tester) async {
    await tester.pumpApp(Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => provider(),
        child: const AttendanceTab(canManage: true),
      ),
    ));
    records.add(const Left(ServerFailure('Attendance down')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ErrorView, 'Attendance down'), findsOneWidget);
  });

  testWidgets('slide to edit saves the new date and time, keeping the id',
      (tester) async {
    await pumpTab(tester);
    await tester.drag(
        find.byKey(Key('attendance-${newer.id}')), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('editAttendance-${newer.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Edit Attendance'), findsOneWidget);
    expect(find.text('5 Jul 2023'), findsOneWidget);
    expect(find.text('8:15 AM'), findsOneWidget);

    await tester.tap(find.byKey(const Key('attendanceDate')));
    await tester.pumpAndSettle();
    await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('3')));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveAttendance')));
    await tester.pumpAndSettle();

    final saved =
        verify(() => update(captureAny())).captured.single as AttendanceRecord;
    expect(saved.id, newer.id);
    expect(saved.isInsideCamp, isTrue);
    expect(saved.timestamp, DateTime(2023, 7, 3, 8, 15));
    expect(find.byType(EditAttendancePage), findsNothing);
    expect(find.text('Attendance updated'), findsOneWidget);
  });

  testWidgets('read-only tiles cannot slide', (tester) async {
    await pumpTab(tester, canManage: false);
    expect(find.byType(Slidable), findsNothing);
    expect(find.text('BOOK IN'), findsOneWidget);
  });
}

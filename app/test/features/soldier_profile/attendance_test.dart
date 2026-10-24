import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/app_list_card.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/core/widgets/icon_plate.dart';
import 'package:trooptrak_final_application/core/widgets/state_tone.dart';
import 'package:trooptrak_final_application/core/widgets/sticky_cta_bar.dart';
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

  testWidgets('rows keep the use case order with in/out labels and plates',
      (tester) async {
    await pumpTab(tester, mode: themeModes.currentValue!);
    final first = tester.getTopLeft(find.text('Wed 5 Jul 2023 08:15:00')).dy;
    final second = tester.getTopLeft(find.text('Tue 4 Jul 2023 18:00:00')).dy;
    expect(first, lessThan(second));
    expect(find.text('BOOK IN'), findsOneWidget);
    expect(find.text('BOOKOUT'), findsOneWidget);
    expect(find.text('Newest first'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(AppListCard),
            matching: find.byType(AttendanceTile)),
        findsNWidgets(2));

    IconPlate plateOf(AttendanceRecord r) =>
        tester.widget<IconPlate>(find.descendant(
            of: find.byKey(Key('attendance-${r.id}')),
            matching: find.byType(IconPlate)));
    expect(plateOf(newer).tone, StateTone.inCamp);
    expect(plateOf(older).tone, StateTone.leave);
    expect(plateOf(newer).icon, isNot(plateOf(older).icon));
  }, variant: themeModes);

  testWidgets('labels take the tone text colour and times use tabular figures',
      (tester) async {
    await pumpTab(tester);
    TextStyle styleOf(String text) =>
        tester.widget<Text>(find.text(text)).style!;
    expect(styleOf('BOOK IN').color, AppPalette.dark.successText);
    expect(styleOf('BOOKOUT').color, AppPalette.dark.leaveText);
    final time = styleOf('Wed 5 Jul 2023 08:15:00');
    expect(time.fontFeatures, [const FontFeature.tabularFigures()]);
    expect(time.color, AppPalette.dark.onCard);
  });

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

  group('EditAttendancePage', () {
    Future<void> pumpEdit(WidgetTester tester,
        {ThemeMode mode = ThemeMode.dark}) async {
      await tester.pumpApp(
        EditAttendancePage(record: newer),
        mode: mode,
        providers: [Provider<UpdateAttendance>.value(value: update)],
      );
    }

    Finder label(String text) => find.byWidgetPredicate(
        (w) => w is Text && w.data == text && w.style?.fontSize == 13.5);

    testWidgets('has a title, a subtitle and the current date and time',
        (tester) async {
      await pumpEdit(tester, mode: themeModes.currentValue!);
      expect(find.text('Edit Attendance'), findsOneWidget);
      expect(find.text('Fill in book in / book out time.'), findsOneWidget);
      expect(find.text('5 Jul 2023'), findsOneWidget);
      expect(find.text('8:15 AM'), findsOneWidget);
    }, variant: themeModes);

    testWidgets('Date and Time labels sit above their fields', (tester) async {
      await pumpEdit(tester);
      for (final (text, key) in [
        ('Date', 'attendanceDate'),
        ('Time', 'attendanceTime'),
      ]) {
        expect(label(text), findsOneWidget);
        final box = tester.getRect(find.descendant(
            of: find.byKey(Key(key)), matching: find.byType(InputDecorator)));
        expect(tester.getRect(label(text)).bottom, lessThanOrEqualTo(box.top));
      }
      expect(tester.getRect(label('Date')).bottom,
          lessThan(tester.getRect(label('Time')).top));
    });

    testWidgets('EDIT ATTENDANCE is pinned below the scrolling form',
        (tester) async {
      await pumpEdit(tester);
      final button = find.byKey(const Key('saveAttendance'));
      expect(find.text('EDIT ATTENDANCE'), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(SingleChildScrollView), matching: button),
          findsNothing);
      expect(find.descendant(of: find.byType(StickyCtaBar), matching: button),
          findsOneWidget);
      expect(tester.getRect(button).bottom,
          lessThanOrEqualTo(tester.view.physicalSize.height));
    });

    testWidgets('saving a new time keeps the date and drops the seconds',
        (tester) async {
      await pumpEdit(tester);
      await tester.tap(find.byKey(const Key('attendanceTime')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      final inputs = find.byType(EditableText);
      await tester.enterText(inputs.at(0), '6');
      await tester.enterText(inputs.at(1), '45');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveAttendance')));
      await tester.pumpAndSettle();

      final saved = verify(() => update(captureAny())).captured.single
          as AttendanceRecord;
      expect(saved.id, newer.id);
      expect(saved.timestamp, DateTime(2023, 7, 5, 6, 45));
    });

    testWidgets('a failed save shows its message and keeps the page',
        (tester) async {
      when(() => update(any()))
          .thenAnswer((_) async => const Left(ServerFailure('No network')));
      await pumpEdit(tester);
      await tester.tap(find.byKey(const Key('saveAttendance')));
      await tester.pumpAndSettle();
      expect(find.text('No network'), findsOneWidget);
      expect(find.byType(EditAttendancePage), findsOneWidget);
      expect(find.text('Attendance updated'), findsNothing);
    });
  });

  testWidgets('read-only tiles cannot slide', (tester) async {
    await pumpTab(tester, canManage: false);
    expect(find.byType(Slidable), findsNothing);
    expect(find.text('BOOK IN'), findsOneWidget);
  });
}

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/feedback_views.dart';
import 'package:trooptrak_final_application/core/widgets/icon_plate.dart';
import 'package:trooptrak_final_application/core/widgets/section_header.dart';
import 'package:trooptrak_final_application/core/widgets/state_tone.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/pages/status_form_page.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/providers/statuses_provider.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/widgets/status_tiles.dart';
import 'package:trooptrak_final_application/features/soldier_profile/presentation/widgets/statuses_tab.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/usecases/status_usecases.dart';

import '../../helpers/builders.dart';
import '../../helpers/fake_clock.dart';
import '../../helpers/pump_app.dart';

class _MockWatch extends Mock implements WatchSoldierStatuses {}

class _MockDelete extends Mock implements DeleteStatus {}

class _MockAdd extends Mock implements AddStatus {}

class _MockUpdate extends Mock implements UpdateStatus {}

void main() {
  late _MockWatch watch;
  late _MockDelete delete;
  late _MockAdd add;
  late _MockUpdate update;
  late StreamController<Either<Failure, List<Status>>> statuses;
  final clock = FixedClock(DateTime(2023, 7, 5, 9));

  final active = buildStatus(
      id: 'a',
      name: 'Ex RMJ',
      start: DateTime(2023, 7, 1),
      end: DateTime(2023, 7, 5));
  final past = buildStatus(
      id: 'p',
      type: 'Leave',
      name: 'OL',
      start: DateTime(2023, 6, 1),
      end: DateTime(2023, 7, 4));

  setUpAll(() {
    registerFallbackValue(buildStatus());
    registerFallbackValue(
        UpdateStatusParams(previous: buildStatus(), updated: buildStatus()));
  });

  setUp(() {
    watch = _MockWatch();
    delete = _MockDelete();
    add = _MockAdd();
    update = _MockUpdate();
    statuses = StreamController<Either<Failure, List<Status>>>();
    when(() => watch(any())).thenAnswer((_) => statuses.stream);
    when(() => delete(any())).thenAnswer((_) async => const Right(unit));
    when(() => add(any())).thenAnswer((_) async => const Right(unit));
    when(() => update(any())).thenAnswer((_) async => const Right(unit));
  });

  tearDown(() => unawaited(statuses.close()));

  StatusesProvider provider() => StatusesProvider(
      watch: watch, delete: delete, clock: clock, soldierId: 'Tan Ah Kow');

  group('StatusesProvider', () {
    test('splits active and past with the fixed clock (R2)', () async {
      final p = provider();
      expect(p.split, isNull);
      statuses.add(Right([past, active]));
      await Future<void>.delayed(Duration.zero);
      expect(p.split!.active, [active]);
      expect(p.split!.past, [past]);
      verify(() => watch('Tan Ah Kow')).called(1);
      p.dispose();
    });

    test('daysLeftLabel counts calendar days to the end day', () {
      final p = provider();
      expect(p.daysLeftLabel(active), 'Ends today');
      expect(p.daysLeftLabel(active.copyWith(end: DateTime(2023, 7, 6))),
          '1 day left');
      expect(p.daysLeftLabel(active.copyWith(end: DateTime(2023, 7, 9))),
          '4 days left');
      p.dispose();
    });

    test('delete returns null or the failure message', () async {
      final p = provider();
      expect(await p.delete(active), isNull);
      when(() => delete(any()))
          .thenAnswer((_) async => const Left(ServerFailure('down')));
      expect(await p.delete(active), 'down');
      p.dispose();
    });
  });

  List<SingleChildWidget> useCases() => [
        Provider<AddStatus>.value(value: add),
        Provider<UpdateStatus>.value(value: update),
      ];

  Future<void> pumpTab(WidgetTester tester,
      {bool canManage = true,
      ThemeMode mode = ThemeMode.dark,
      List<Status>? shown}) async {
    await tester.pumpApp(
      Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => provider(),
          child: StatusesTab(canManage: canManage),
        ),
      ),
      mode: mode,
      clock: clock,
      providers: useCases(),
    );
    statuses.add(Right(shown ?? [active, past]));
    await tester.pumpAndSettle();
  }

  group('StatusesTab', () {
    testWidgets('active cards and past rows in their sections', (tester) async {
      await pumpTab(tester, mode: themeModes.currentValue!);
      expect(find.text('Active Statuses'), findsOneWidget);
      expect(find.text('Past Statuses'), findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const Key('activeStatuses')),
              matching: find.text('Ex RMJ')),
          findsOneWidget);
      expect(find.text('LEAVE · 1 Jun 2023 - 4 Jul 2023'), findsOneWidget);
      expect(find.text('EXCUSE'), findsOneWidget);
      expect(find.text('1 Jul 2023 - 5 Jul 2023'), findsOneWidget);
    }, variant: themeModes);

    testWidgets('each section shows how many statuses it holds',
        (tester) async {
      await pumpTab(tester);
      final headers = find.byType(SectionHeader);
      expect(
          find.descendant(
              of: find.ancestor(
                  of: find.text('Active Statuses'), matching: headers),
              matching: find.text('1')),
          findsOneWidget);
      expect(
          find.descendant(
              of: find.ancestor(
                  of: find.text('Past Statuses'), matching: headers),
              matching: find.text('1')),
          findsOneWidget);
    });

    testWidgets('an active card says how many days are left', (tester) async {
      final soon = buildStatus(
          id: 'soon',
          type: 'Leave',
          name: 'Block Leave',
          start: DateTime(2023, 7, 1),
          end: DateTime(2023, 7, 6));
      final later = buildStatus(
          id: 'later',
          type: 'Medical Appointment',
          name: 'Dental',
          start: DateTime(2023, 7, 1),
          end: DateTime(2023, 7, 9));
      await pumpTab(tester, shown: [active, soon, later, past]);
      Finder badge(String id, String text) => find.descendant(
          of: find.byKey(Key('activeStatus-$id')), matching: find.text(text));
      expect(badge('a', 'Ends today'), findsOneWidget);
      expect(badge('soon', '1 day left'), findsOneWidget);
      expect(badge('later', '4 days left'), findsOneWidget);
    });

    testWidgets('an active card is a gradient of its status type',
        (tester) async {
      final leave = buildStatus(
          id: 'lv',
          type: 'Leave',
          name: 'Block Leave',
          end: DateTime(2023, 7, 8));
      final medical = buildStatus(
          id: 'ma',
          type: 'Medical Appointment',
          name: 'Dental',
          end: DateTime(2023, 7, 8));
      await pumpTab(tester, shown: [active, leave, medical]);
      for (final (id, tone) in [
        ('a', StateTone.excuse),
        ('lv', StateTone.leave),
        ('ma', StateTone.medical),
      ]) {
        final box = tester.widget<Ink>(find.descendant(
            of: find.byKey(Key('activeStatus-$id')),
            matching: find.byType(Ink)));
        final gradient =
            (box.decoration! as BoxDecoration).gradient! as LinearGradient;
        expect(gradient.colors, tone.gradient(AppPalette.dark));
        expect(gradient.colors.first, tone.fill(AppPalette.dark));
        expect(gradient.colors.first, isNot(gradient.colors.last));
      }
    });

    testWidgets('a past row has a plate of its type and tone', (tester) async {
      await pumpTab(tester);
      final plate = find.descendant(
          of: find.byKey(const Key('pastStatus-p')),
          matching: find.byType(IconPlate));
      expect(plate, findsOneWidget);
      final widget = tester.widget<IconPlate>(plate);
      expect(widget.icon, statusIcon('Leave'));
      expect(widget.tone, StateTone.leave);
      expect(statusIcon('Leave'), isNot(statusIcon('Medical Appointment')));
      expect(statusIcon('Excuse'), isNot(statusIcon('Leave')));
    });

    testWidgets('an empty list says so instead of leaving a gap',
        (tester) async {
      await pumpTab(tester, shown: const []);
      expect(find.text('No active statuses'), findsOneWidget);
      expect(find.text('No past statuses'), findsOneWidget);
      expect(find.byKey(const Key('activeStatuses')), findsNothing);
      expect(find.byKey(const Key('addStatus')), findsOneWidget);
    });

    testWidgets('active delete icon calls the use case', (tester) async {
      await pumpTab(tester);
      await tester.tap(find.byKey(const Key('deleteStatus-a')));
      await tester.pumpAndSettle();
      verify(() => delete(active)).called(1);
      expect(find.text('Status deleted'), findsOneWidget);
    });

    testWidgets('a failed delete shows the error snackbar', (tester) async {
      when(() => delete(any()))
          .thenAnswer((_) async => const Left(ServerFailure('No network')));
      await pumpTab(tester);
      await tester.tap(find.byKey(const Key('deleteStatus-a')));
      await tester.pumpAndSettle();
      expect(find.text('No network'), findsOneWidget);
      expect(find.text('Status deleted'), findsNothing);
    });

    testWidgets('a failed status stream shows the error', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: ChangeNotifierProvider(
            create: (_) => provider(),
            child: const StatusesTab(canManage: true),
          ),
        ),
        clock: clock,
        providers: useCases(),
      );
      statuses.add(const Left(ServerFailure('Statuses down')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ErrorView, 'Statuses down'), findsOneWidget);
    });

    testWidgets('past row slides to delete', (tester) async {
      await pumpTab(tester);
      await tester.drag(
          find.byKey(const Key('pastStatus-p')), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('deletePastStatus-p')));
      await tester.pumpAndSettle();
      verify(() => delete(past)).called(1);
    });

    testWidgets('past row slides to edit', (tester) async {
      await pumpTab(tester);
      await tester.drag(
          find.byKey(const Key('pastStatus-p')), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('editStatus-p')));
      await tester.pumpAndSettle();
      expect(find.text('UPDATE STATUS'), findsOneWidget);
    });

    testWidgets('commanders are told to slide, soldiers are not',
        (tester) async {
      await pumpTab(tester);
      expect(find.text('Slide a row left to edit or delete'), findsOneWidget);
      await pumpTab(tester, canManage: false);
      expect(find.text('Slide a row left to edit or delete'), findsNothing);
    });

    testWidgets('long names and many cards fit without overflow',
        (tester) async {
      final long = buildStatus(
          id: 'long',
          type: 'Medical Appointment',
          name: 'Review of the post operation recovery with the specialist',
          end: DateTime(2023, 7, 20));
      await pumpTab(tester, shown: [active, long, past]);
      expect(tester.takeException(), isNull);
      final heights = [
        for (final id in ['a', 'long'])
          tester.getSize(find.byKey(Key('activeStatus-$id'))).height,
      ];
      expect(heights.first, heights.last);
    });

    testWidgets('tapping an active card opens the update form', (tester) async {
      await pumpTab(tester);
      await tester.tap(find.byKey(const Key('activeStatus-a')));
      await tester.pumpAndSettle();
      expect(find.text('Edit the status for this soldier ✍️'), findsOneWidget);
      expect(find.text('UPDATE STATUS'), findsOneWidget);
    });

    testWidgets('read-only mode has no add, edit or delete', (tester) async {
      await pumpTab(tester, canManage: false);
      expect(find.byKey(const Key('addStatus')), findsNothing);
      expect(find.byKey(const Key('deleteStatus-a')), findsNothing);
      expect(find.byType(Slidable), findsNothing);
      await tester.tap(find.byKey(const Key('activeStatus-a')));
      await tester.pumpAndSettle();
      expect(find.text('UPDATE STATUS'), findsNothing);
    });
  });

  group('StatusFormPage', () {
    Future<void> pumpForm(WidgetTester tester, {Status? status}) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      StatusFormPage(soldierId: 'Tan Ah Kow', status: status),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
        clock: clock,
        providers: useCases(),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Future<void> typeName(WidgetTester tester, String name) async {
      await tester.enterText(find.byType(TextFormField), name);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    }

    Future<void> save(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('saveStatus')));
      await tester.pumpAndSettle();
    }

    testWidgets('empty add shows the source validation texts', (tester) async {
      await pumpForm(tester);
      expect(find.text("Let's add a new status for this soldier ✍️"),
          findsOneWidget);
      await save(tester);
      expect(find.text('Bruh select Dei!'), findsOneWidget);
      expect(find.text('Oi can enter the status type please?'), findsOneWidget);
      expect(find.text('Details missing'), findsOneWidget);
      verifyNever(() => add(any()));
    });

    testWidgets('name suggestions filter as you type', (tester) async {
      await pumpForm(tester);
      await tester.enterText(find.byType(TextFormField), 'limb');
      await tester.pumpAndSettle();
      expect(find.text('Ex Upper Limb'), findsOneWidget);
      expect(find.text('Ex Lower Limb'), findsOneWidget);
      await tester.tap(find.text('Ex Upper Limb'));
      await tester.pumpAndSettle();
      expect(find.text('LD'), findsNothing);
    });

    testWidgets('valid add saves today-dated status and pops', (tester) async {
      await pumpForm(tester);
      await tester.tap(find.byKey(const Key('statusType')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave').last);
      await tester.pumpAndSettle();
      await typeName(tester, ' OL ');
      await save(tester);

      final saved = verify(() => add(captureAny())).captured.single as Status;
      expect(saved.soldierId, 'Tan Ah Kow');
      expect(saved.type, 'Leave');
      expect(saved.name, ' OL ');
      expect(saved.start, clock.now());
      expect(saved.end, clock.now());
      expect(find.text('Status added successfully!'), findsOneWidget);
      expect(find.byType(StatusFormPage), findsNothing);
    });

    testWidgets('update passes the previous and edited status', (tester) async {
      await pumpForm(tester, status: active);
      expect(find.text('Ex RMJ'), findsOneWidget);
      await typeName(tester, 'LD');
      await save(tester);
      final params = verify(() => update(captureAny())).captured.single
          as UpdateStatusParams;
      expect(params.previous, active);
      expect(params.updated, active.copyWith(name: 'LD'));
    });

    testWidgets('a domain failure (K18) is shown and the form stays',
        (tester) async {
      when(() => update(any())).thenAnswer(
          (_) async => const Left(ValidationFailure(endBeforeStart)));
      await pumpForm(tester, status: active);
      await save(tester);
      expect(find.text(endBeforeStart), findsOneWidget);
      expect(find.byType(StatusFormPage), findsOneWidget);
    });
  });
}

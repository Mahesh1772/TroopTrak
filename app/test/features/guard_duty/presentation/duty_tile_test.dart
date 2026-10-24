import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/primary_button.dart';
import 'package:trooptrak_final_application/core/widgets/rank_chip.dart';
import 'package:trooptrak_final_application/core/widgets/rank_plate.dart';
import 'package:trooptrak_final_application/core/widgets/state_chip.dart';
import 'package:trooptrak_final_application/core/widgets/state_tone.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/entities/duty.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/widgets/duty_participant_row.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/widgets/duty_points_chip.dart';
import 'package:trooptrak_final_application/features/guard_duty/presentation/widgets/duty_tile.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/pump_app.dart';

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

Duty _duty({
  int people = 6,
  DateTime? end,
  String dayType = 'Weekday Duty 🫣',
  double points = 1.0,
}) =>
    buildDuty(
      id: 'x',
      start: DateTime(2023, 7, 5, 8),
      end: end ?? DateTime(2023, 7, 5, 8),
      dayType: dayType,
      points: points,
      participants: {
        for (var i = 0; i < people; i++) 'Soldier $i': i == 1 ? 'CFC' : 'PTE',
      },
    );

Finder _inTile(Finder finder) =>
    find.descendant(of: find.byKey(const Key('duty-x')), matching: finder);

Color _tickColor(WidgetTester tester, int index) {
  final box = tester.widget<AnimatedContainer>(
      _inTile(find.byKey(ValueKey('tick-0-$index'))));
  return (box.decoration! as BoxDecoration).color!;
}

Future<void> _pumpTile(
  WidgetTester tester,
  Duty duty, {
  bool? participating,
  bool Function(String name)? isSelf,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  ThemeMode mode = ThemeMode.dark,
}) async {
  await tester.pumpApp(
    Scaffold(
      body: SingleChildScrollView(
        child: DutyTile(
          duty: duty,
          participating: participating,
          isSelf: isSelf,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    ),
    mode: mode,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('the card', () {
    testWidgets('shows points, day type without emoji, time and date',
        (tester) async {
      await _pumpTile(
        tester,
        _duty(
          dayType: 'Weekday (Friday) Duty 😖',
          points: 1.5,
          end: DateTime(2023, 7, 5, 20),
        ),
        mode: themeModes.currentValue!,
      );
      expect(find.byType(DutyPointsChip), findsOneWidget);
      expect(find.text('1.5'), findsOneWidget);
      expect(find.text('PTS'), findsOneWidget);
      expect(find.text('Weekday (Friday) Duty'), findsOneWidget);
      expect(find.textContaining('😖'), findsNothing);
      expect(find.text('8:00 AM – 8:00 PM'), findsOneWidget);
      expect(find.text('Wed 5 Jul 2023'), findsOneWidget);
    }, variant: themeModes);

    testWidgets('the points chip is an accent pill in both themes',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pumpTile(tester, _duty(), mode: mode);
      final chip = find.byType(DutyPointsChip);
      final decoration = tester
          .widget<DecoratedBox>(find
              .descendant(of: chip, matching: find.byType(DecoratedBox))
              .first)
          .decoration as ShapeDecoration;
      expect(decoration.color, StateTone.accent.tint(palette));
      expect(tester.widget<Text>(find.text('1.0')).style!.color,
          StateTone.accent.text(palette));
    }, variant: themeModes);

    testWidgets('"(Next day)" shows only when the end is not after the start',
        (tester) async {
      await _pumpTile(tester, _duty());
      expect(find.text('8:00 AM – 8:00 AM (Next day)'), findsOneWidget);

      await _pumpTile(tester, _duty(end: DateTime(2023, 7, 5, 7)));
      expect(find.textContaining('(Next day)'), findsOneWidget);

      await _pumpTile(tester, _duty(end: DateTime(2023, 7, 5, 22)));
      expect(find.text('8:00 AM – 10:00 PM'), findsOneWidget);
      expect(find.textContaining('(Next day)'), findsNothing);
    });

    testWidgets('the time is in the card text colour, "(Next day)" muted',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pumpTile(tester, _duty(), mode: mode);
      final text =
          tester.widget<Text>(find.text('8:00 AM – 8:00 AM (Next day)'));
      final span = text.textSpan! as TextSpan;
      expect(text.style!.color, palette.onCard);
      expect(text.style!.fontSize, 24);
      expect((span.children!.single as TextSpan).style!.color,
          palette.secondaryText);
    }, variant: themeModes);

    testWidgets('the card sits on the palette card colour', (tester) async {
      final mode = themeModes.currentValue!;
      await _pumpTile(tester, _duty(), mode: mode);
      final material = tester.widget<Material>(find
          .descendant(
            of: find.byKey(const Key('duty-x')),
            matching: find.byType(Material),
          )
          .first);
      expect(material.color, _paletteOf(mode).card);
    }, variant: themeModes);
  });

  group('the 10-slot bar', () {
    testWidgets('ten ticks, the filled ones pink and the rest off',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pumpTile(tester, _duty(people: 6), mode: mode);
      for (var i = 0; i < 10; i++) {
        expect(_tickColor(tester, i), i < 6 ? palette.duty : palette.tickOff,
            reason: 'slot $i');
      }
      expect(_inTile(find.byKey(const ValueKey('tick-0-10'))), findsNothing);
    }, variant: themeModes);

    testWidgets('an empty duty fills no slot, a full one fills all',
        (tester) async {
      final palette = AppPalette.dark;
      await _pumpTile(tester, _duty(people: 0));
      expect([for (var i = 0; i < 10; i++) _tickColor(tester, i)],
          everyElement(palette.tickOff));
      await _pumpTile(tester, _duty(people: 10));
      expect([for (var i = 0; i < 10; i++) _tickColor(tester, i)],
          everyElement(palette.duty));
    });

    testWidgets('the count reads "6 / 10" and is announced', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(tester, _duty(people: 6));
      expect(find.text('Participants'), findsOneWidget);
      expect(find.text('6 / 10'), findsOneWidget);
      expect(find.bySemanticsLabel('6 of 10 slots filled'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the bar is 10 px high', (tester) async {
      await _pumpTile(tester, _duty());
      expect(
          tester
              .getSize(_inTile(find.byKey(const ValueKey('tick-0-0'))))
              .height,
          10);
    });
  });

  group('On duty and You', () {
    testWidgets('no chip when nobody is tracked (commander)', (tester) async {
      await _pumpTile(tester, _duty());
      expect(find.byKey(const Key('onDuty-x')), findsNothing);
      expect(find.byKey(const Key('offDuty-x')), findsNothing);
    });

    testWidgets('On duty is a green check chip, Not on duty a grey cross',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pumpTile(tester, _duty(), participating: true, mode: mode);
      var chip = tester.widget<StateChip>(find.byKey(const Key('onDuty-x')));
      expect([chip.label, chip.tone, chip.icon],
          ['On duty', StateTone.inCamp, Icons.check_rounded]);
      expect(tester.widget<Text>(find.text('On duty')).style!.color,
          StateTone.inCamp.text(palette));

      await _pumpTile(tester, _duty(), participating: false, mode: mode);
      chip = tester.widget<StateChip>(find.byKey(const Key('offDuty-x')));
      expect([chip.label, chip.tone, chip.icon],
          ['Not on duty', StateTone.out, Icons.close_rounded]);
      expect(find.byKey(const Key('onDuty-x')), findsNothing);
    }, variant: themeModes);

    testWidgets('the signed-in soldier\'s row carries a You chip',
        (tester) async {
      await _pumpTile(
        tester,
        _duty(people: 3),
        participating: true,
        isSelf: (name) => name == 'Soldier 1',
      );
      await tester.tap(find.byKey(const Key('duty-x')));
      await tester.pumpAndSettle();
      final rows = tester
          .widgetList<DutyParticipantRow>(find.byType(DutyParticipantRow))
          .toList();
      expect([for (final r in rows) r.isSelf], [false, true, false]);
      expect(find.text('You'), findsOneWidget);
      expect(
          tester.widget<StateChip>(find.widgetWithText(StateChip, 'You')).tone,
          StateTone.accent);
    });

    testWidgets('no You chip without a signed-in soldier', (tester) async {
      await _pumpTile(tester, _duty(people: 3));
      await tester.tap(find.byKey(const Key('duty-x')));
      await tester.pumpAndSettle();
      expect(find.text('You'), findsNothing);
    });
  });

  group('participants and actions', () {
    testWidgets('each row has a 32 px plate, the name and the rank chip',
        (tester) async {
      await _pumpTile(tester, _duty(people: 2), mode: themeModes.currentValue!);
      expect(find.byType(DutyParticipantRow), findsNothing);
      await tester.tap(find.byKey(const Key('duty-x')));
      await tester.pumpAndSettle();
      expect(find.byType(DutyParticipantRow), findsNWidgets(2));
      expect(find.text('Soldier 0'), findsOneWidget);
      expect(find.text('Soldier 1'), findsOneWidget);
      expect(find.byType(RankChip), findsNWidgets(2));
      final plate = find.descendant(
          of: find.byType(DutyParticipantRow),
          matching: find.byType(RankPlate));
      expect(tester.getSize(plate.first), const Size.square(32));
      expect(find.text('PTE'), findsOneWidget);
      expect(find.text('CFC'), findsOneWidget);
    }, variant: themeModes);

    testWidgets('EDIT and DELETE show for commanders, side by side',
        (tester) async {
      var edited = 0;
      var deleted = 0;
      await _pumpTile(
        tester,
        _duty(),
        onEdit: () => edited++,
        onDelete: () => deleted++,
        mode: themeModes.currentValue!,
      );
      expect(find.byKey(const Key('editDuty-x')), findsNothing);
      await tester.tap(find.byKey(const Key('duty-x')));
      await tester.pumpAndSettle();
      final edit = find.byKey(const Key('editDuty-x'));
      final delete = find.byKey(const Key('deleteDuty-x'));
      expect(
          tester.widget<PrimaryButton>(edit).style, PrimaryButtonStyle.ghost);
      expect(tester.widget<PrimaryButton>(delete).style,
          PrimaryButtonStyle.danger);
      expect(tester.getTopLeft(edit).dy, tester.getTopLeft(delete).dy);
      expect(tester.getSize(edit).width, tester.getSize(delete).width);
      await tester.tap(edit);
      await tester.tap(delete);
      expect([edited, deleted], [1, 1]);
    }, variant: themeModes);

    testWidgets('a read-only card has neither', (tester) async {
      await _pumpTile(tester, _duty());
      await tester.tap(find.byKey(const Key('duty-x')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('editDuty-x')), findsNothing);
      expect(find.byKey(const Key('deleteDuty-x')), findsNothing);
    });
  });
}

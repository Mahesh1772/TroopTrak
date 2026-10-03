import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/widgets/app_dropdown_field.dart';
import 'package:trooptrak_final_application/core/widgets/horizontal_date_strip.dart';
import 'package:trooptrak_final_application/core/widgets/picker_fields.dart';
import 'package:trooptrak_final_application/core/widgets/primary_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('AppDropdownField shows hint and reports selection',
      (tester) async {
    String? selected;
    await tester.pumpThemed(
      AppDropdownField<String>(
        items: const ['NM', 'M', 'VC'],
        hintText: 'Select your ration type...',
        onChanged: (v) => selected = v,
      ),
      mode: themeModes.currentValue!,
    );
    expect(find.text('Select your ration type...'), findsOneWidget);

    await tester.tap(find.text('Select your ration type...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('VC').last);
    await tester.pumpAndSettle();
    expect(selected, 'VC');
  }, variant: themeModes);

  testWidgets('AppDropdownField shows the current value', (tester) async {
    await tester.pumpThemed(AppDropdownField<String>(
      items: const ['A+', 'B+'],
      value: 'B+',
      hintText: 'Blood',
      onChanged: (_) {},
    ));
    expect(find.text('B+'), findsOneWidget);
    expect(find.text('Blood'), findsNothing);
  });

  testWidgets('DatePickerField formats value and returns picked date',
      (tester) async {
    DateTime? picked;
    await tester.pumpThemed(
      DatePickerField(
        hintText: 'Date of Birth',
        value: DateTime(2023, 7, 5),
        firstDate: DateTime(2023, 1, 1),
        lastDate: DateTime(2023, 12, 31),
        onChanged: (d) => picked = d,
      ),
      mode: themeModes.currentValue!,
    );
    expect(find.text('5 Jul 2023'), findsOneWidget);

    await tester.tap(find.text('5 Jul 2023'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(picked, DateTime(2023, 7, 20));
  }, variant: themeModes);

  testWidgets('DatePickerField shows hint and error when empty',
      (tester) async {
    await tester.pumpThemed(DatePickerField(
      hintText: 'ORD',
      errorText: 'Required',
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      onChanged: (_) {},
    ));
    expect(find.text('ORD'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('TimePickerField formats value as jm and returns picked time',
      (tester) async {
    TimeOfDay? picked;
    await tester.pumpThemed(
      TimePickerField(
        hintText: 'Start time',
        value: const TimeOfDay(hour: 17, minute: 30),
        onChanged: (t) => picked = t,
      ),
      mode: themeModes.currentValue!,
    );
    expect(find.text('5:30 PM'), findsOneWidget);

    await tester.tap(find.text('5:30 PM'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(picked, const TimeOfDay(hour: 17, minute: 30));
  }, variant: themeModes);

  testWidgets('HorizontalDateStrip highlights and reports a tapped day',
      (tester) async {
    DateTime? tapped;
    await tester.pumpThemed(
      HorizontalDateStrip(
        firstDate: DateTime(2023, 7, 1),
        lastDate: DateTime(2023, 7, 31),
        selectedDate: DateTime(2023, 7, 10),
        onDateSelected: (d) => tapped = d,
      ),
      mode: themeModes.currentValue!,
    );
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('date-strip-10 Jul 2023')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('date-strip-11 Jul 2023')));
    expect(tapped, DateTime(2023, 7, 11));
  }, variant: themeModes);

  testWidgets('HorizontalDateStrip scrolls the selected day into view',
      (tester) async {
    await tester.pumpThemed(HorizontalDateStrip(
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2025, 12, 31),
      selectedDate: DateTime(2024, 6, 15),
      onDateSelected: (_) {},
    ));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('date-strip-15 Jun 2024')), findsOneWidget);
  });

  group('PrimaryButton', () {
    testWidgets('fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpThemed(
        PrimaryButton(
            label: 'Submit', icon: Icons.add, onPressed: () => taps++),
        mode: themeModes.currentValue!,
      );
      await tester.tap(find.text('Submit'));
      expect(taps, 1);
      expect(find.byIcon(Icons.add), findsOneWidget);
    }, variant: themeModes);

    testWidgets('loading shows a spinner and ignores taps', (tester) async {
      var taps = 0;
      await tester.pumpThemed(PrimaryButton(
          label: 'Submit', loading: true, onPressed: () => taps++));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
      await tester.tap(find.byType(PrimaryButton));
      expect(taps, 0);
    });

    testWidgets('null onPressed is disabled', (tester) async {
      await tester
          .pumpThemed(const PrimaryButton(label: 'Go', onPressed: null));
      await tester.tap(find.text('Go'));
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.5);
    });
  });
}

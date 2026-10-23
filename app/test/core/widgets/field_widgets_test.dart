import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/app_dropdown_field.dart';
import 'package:trooptrak_final_application/core/widgets/app_search_field.dart';
import 'package:trooptrak_final_application/core/widgets/field_chrome.dart';
import 'package:trooptrak_final_application/core/widgets/horizontal_date_strip.dart';
import 'package:trooptrak_final_application/core/widgets/picker_fields.dart';

import '../../helpers/pump_app.dart';

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

void main() {
  group('labels above fields', () {
    testWidgets('LabeledField without a label is just the child',
        (tester) async {
      await tester
          .pumpThemed(const LabeledField(child: SizedBox(key: Key('child'))));
      expect(find.byType(Column), findsNothing);
    });

    testWidgets('a dropdown puts its label 6 px above a 52 px field',
        (tester) async {
      final palette = _paletteOf(themeModes.currentValue!);
      await tester.pumpThemed(
        AppDropdownField<String>(
          label: 'Ration type',
          items: const ['NM', 'M'],
          hintText: 'Select...',
          prefixIcon: Icons.restaurant,
          onChanged: (_) {},
        ),
        mode: themeModes.currentValue!,
      );
      final label = find.text('Ration type');
      final input = find.byType(InputDecorator);
      final style = tester.widget<Text>(label).style!;

      expect(tester.getSize(input).height, 52);
      expect(tester.getRect(input).top - tester.getRect(label).bottom, 6);
      expect(tester.getTopLeft(label).dx - tester.getTopLeft(input).dx, 4);
      expect([style.fontSize, style.fontWeight], [13.5, FontWeight.w500]);
      expect(style.color, palette.secondaryText);
      expect(find.byIcon(Icons.expand_more_rounded), findsOneWidget);
    }, variant: themeModes);

    testWidgets('a date field puts its label above and keeps the hint inside',
        (tester) async {
      await tester.pumpThemed(DatePickerField(
        label: 'Date of Birth:',
        hintText: 'Pick a date',
        firstDate: DateTime(2000),
        lastDate: DateTime(2030),
        onChanged: (_) {},
      ));
      final input = find.byType(InputDecorator);

      expect(find.text('Date of Birth:'), findsOneWidget);
      expect(find.text('Pick a date'), findsOneWidget);
      expect(tester.getSize(input).height, 52);
      expect(tester.getRect(find.text('Date of Birth:')).bottom,
          lessThan(tester.getRect(input).top));
    });

    testWidgets('a time field shows its label and the value in tabular figures',
        (tester) async {
      await tester.pumpThemed(TimePickerField(
        label: 'Start Time:',
        hintText: 'Start',
        value: const TimeOfDay(hour: 8, minute: 0),
        onChanged: (_) {},
      ));
      final value = tester.widget<Text>(find.text('8:00 AM')).style!;

      expect(find.text('Start Time:'), findsOneWidget);
      expect(value.fontFamily, startsWith('BarlowCondensed'));
      expect(value.fontSize, 17);
      expect(value.fontFeatures, [const FontFeature.tabularFigures()]);
      expect(tester.getSize(find.byType(InputDecorator)).height, 52);
    });

    testWidgets('the leading icon is 20 px, 14 px from the edge, 10 from text',
        (tester) async {
      await tester.pumpThemed(TimePickerField(
        hintText: 'Start',
        value: const TimeOfDay(hour: 8, minute: 0),
        onChanged: (_) {},
      ));
      final input = tester.getRect(find.byType(InputDecorator));
      final icon = find.byIcon(Icons.access_time_rounded);

      expect(tester.widget<Icon>(icon).size, 20);
      expect(tester.getTopLeft(icon).dx - input.left, 14);
      expect(
          tester.getTopLeft(find.text('8:00 AM')).dx -
              tester.getTopRight(icon).dx,
          10);
    });

    testWidgets('a picker error shows in the legible red', (tester) async {
      await tester.pumpThemed(DatePickerField(
        hintText: 'ORD',
        errorText: 'Required',
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        onChanged: (_) {},
      ));
      final style = tester.widget<Text>(find.text('Required')).style!;
      expect(style.color, AppPalette.dark.leaveText);
    });
  });

  group('AppSearchField', () {
    testWidgets('is a 46 px field with a 24 px magnifier', (tester) async {
      await tester.pumpThemed(
        AppSearchField(onChanged: (_) {}),
        mode: themeModes.currentValue!,
      );

      expect(tester.getSize(find.byType(InputDecorator)).height, 46);
      expect(tester.widget<Icon>(find.byIcon(Icons.search_rounded)).size, 24);
    }, variant: themeModes);

    testWidgets('draws a half-height radius on the card fill', (tester) async {
      final mode = themeModes.currentValue!;
      await tester.pumpThemed(AppSearchField(onChanged: (_) {}), mode: mode);
      final theme = Theme.of(tester.element(find.byType(TextField)));
      final decoration = theme.inputDecorationTheme;

      expect((decoration.border! as OutlineInputBorder).borderRadius,
          BorderRadius.circular(23));
      expect(decoration.fillColor, _paletteOf(mode).cardElevated);
      expect(decoration.focusedBorder!.borderSide.width, 2);
      expect(
          decoration.focusedBorder!.borderSide.color, _paletteOf(mode).accent);
    }, variant: themeModes);

    testWidgets('keeps its height while focused', (tester) async {
      await tester.pumpThemed(AppSearchField(onChanged: (_) {}));
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(InputDecorator)).height, 46);
    });

    testWidgets('shows a custom hint and reports typing', (tester) async {
      final typed = <String>[];
      await tester.pumpThemed(
          AppSearchField(hintText: 'Search Name', onChanged: typed.add));
      expect(find.text('Search Name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'ho');
      expect(typed, ['ho']);
    });
  });

  group('HorizontalDateStrip tiles', () {
    Future<void> pump(WidgetTester tester, {ThemeMode? mode}) async {
      await tester.pumpThemed(
        HorizontalDateStrip(
          firstDate: DateTime(2023, 7, 1),
          lastDate: DateTime(2023, 7, 31),
          selectedDate: DateTime(2023, 7, 10),
          onDateSelected: (_) {},
        ),
        mode: mode ?? ThemeMode.dark,
      );
      await tester.pumpAndSettle();
    }

    Finder tile(int day) => find.byKey(ValueKey('date-strip-$day Jul 2023'));

    Finder box(int day) => find.descendant(
        of: tile(day), matching: find.byType(AnimatedContainer));

    BoxDecoration decorationOf(WidgetTester tester, int day) =>
        tester.widget<AnimatedContainer>(box(day)).decoration! as BoxDecoration;

    testWidgets('strip is 72 high and each tile 54 wide with 8 px gaps',
        (tester) async {
      await pump(tester);
      expect(tester.getSize(find.byType(HorizontalDateStrip)).height, 72);
      expect(tester.getSize(box(9)), const Size(54, 72));
      expect(
          tester.getTopLeft(tile(11)).dx - tester.getTopLeft(tile(10)).dx, 62);
    });

    testWidgets('the selected day is on the header gradient, the rest on card',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await pump(tester, mode: mode);

      final selected = decorationOf(tester, 10);
      expect((selected.gradient! as LinearGradient).colors,
          palette.headerGradient);
      expect(selected.color, isNull);
      expect(selected.borderRadius, BorderRadius.circular(16));

      final other = decorationOf(tester, 11);
      expect(other.gradient, isNull);
      expect(other.color, palette.card);
    }, variant: themeModes);

    testWidgets('shows month, day and weekday in capitals', (tester) async {
      await pump(tester);
      final texts = tester
          .widgetList<Text>(
              find.descendant(of: tile(10), matching: find.byType(Text)))
          .toList();

      expect(texts.map((t) => t.data), ['JUL', '10', 'MON']);
      expect(texts[1].style!.fontFamily, startsWith('BarlowCondensed'));
      expect(texts[1].style!.fontSize, 24);
      expect(texts[1].style!.color, AppColors.white);
      expect(texts[0].style!.color, AppColors.onGradientLabel);
      expect(texts[0].style!.fontSize, 11.5);
    });

    testWidgets('an unselected tile uses card text colours', (tester) async {
      final palette = _paletteOf(ThemeMode.dark);
      await pump(tester);
      final texts = tester
          .widgetList<Text>(
              find.descendant(of: tile(11), matching: find.byType(Text)))
          .toList();

      expect(texts[0].style!.color, palette.secondaryText);
      expect(texts[1].style!.color, palette.onCard);
    });

    testWidgets('the selected tile is centred', (tester) async {
      await pump(tester);
      expect(tester.getCenter(box(10)).dx, closeTo(195, 1));
    });

    testWidgets('moves the gradient when the selected day changes',
        (tester) async {
      var selected = DateTime(2023, 7, 10);
      await tester.pumpThemed(StatefulBuilder(
        builder: (context, setState) => HorizontalDateStrip(
          firstDate: DateTime(2023, 7, 1),
          lastDate: DateTime(2023, 7, 31),
          selectedDate: selected,
          onDateSelected: (d) => setState(() => selected = d),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(tile(12));
      await tester.pumpAndSettle();

      expect(decorationOf(tester, 12).gradient, isNotNull);
      expect(decorationOf(tester, 10).gradient, isNull);
    });
  });
}

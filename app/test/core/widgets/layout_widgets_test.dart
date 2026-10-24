import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trooptrak_final_application/core/theme/app_layout.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/theme/theme_context.dart';
import 'package:trooptrak_final_application/core/widgets/app_list_card.dart';
import 'package:trooptrak_final_application/core/widgets/date_header.dart';
import 'package:trooptrak_final_application/core/widgets/gradient_header.dart';
import 'package:trooptrak_final_application/core/widgets/page_title.dart';
import 'package:trooptrak_final_application/core/widgets/section_header.dart';

import '../../helpers/pump_app.dart';

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

Future<void> _loadFonts(WidgetTester tester) => tester.runAsync(() async {
      for (final weight in [FontWeight.w400, FontWeight.w600]) {
        GoogleFonts.barlow(fontWeight: weight);
      }
      GoogleFonts.barlow(fontWeight: FontWeight.w700);
      await GoogleFonts.pendingFonts();
    });

Future<void> _pumpUnder(
  WidgetTester tester,
  Widget child, {
  double statusBar = 0,
  ThemeMode mode = ThemeMode.dark,
}) async {
  await _loadFonts(tester);
  await tester.pumpThemed(
    MediaQuery(
      data: MediaQueryData(
        size: designSize,
        padding: EdgeInsets.only(top: statusBar),
      ),
      child: Align(alignment: Alignment.topLeft, child: child),
    ),
    mode: mode,
    wrapInScaffold: false,
  );
}

BoxDecoration _decorationOf(WidgetTester tester, Finder within) => tester
    .widget<DecoratedBox>(
        find.descendant(of: within, matching: find.byType(DecoratedBox)).first)
    .decoration as BoxDecoration;

void main() {
  group('GradientHeader', () {
    testWidgets('paints the brand gradient across the full width',
        (tester) async {
      final mode = themeModes.currentValue!;
      await _pumpUnder(
        tester,
        const GradientHeader(
            child: SizedBox(height: 40, child: Text('greeting'))),
        mode: mode,
      );
      final gradient = _decorationOf(tester, find.byType(GradientHeader))
          .gradient! as LinearGradient;
      expect(gradient.colors, _paletteOf(mode).headerGradient);
      expect(tester.getSize(find.byType(GradientHeader)).width, 390);
    }, variant: themeModes);

    testWidgets('the child starts below the status bar, the gradient above it',
        (tester) async {
      await _pumpUnder(
        tester,
        const GradientHeader(
            child: SizedBox(height: 40, child: Text('greeting'))),
        statusBar: 44,
      );
      final header = tester.getRect(find.byType(GradientHeader));
      expect(header.top, 0);
      expect(tester.getTopLeft(find.text('greeting')).dy, 44);
      expect(header.height, 44 + 40 + 22);
    });

    testWidgets('bottom space is configurable in design px', (tester) async {
      await _pumpUnder(
        tester,
        const GradientHeader(
          bottom: 64,
          child: SizedBox(height: 40),
        ),
      );
      expect(tester.getSize(find.byType(GradientHeader)).height, 40 + 64);
    });

    testWidgets('asks for light status bar icons over the gradient',
        (tester) async {
      await _pumpUnder(tester, const GradientHeader(child: SizedBox()));
      final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.descendant(
          of: find.byType(GradientHeader),
          matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
        ),
      );
      expect(region.value.statusBarColor, Colors.transparent);
      expect(region.value.statusBarIconBrightness, Brightness.light);
      expect(region.value.statusBarBrightness, Brightness.dark);
    });
  });

  group('AppListCard and AppListRow', () {
    Widget card({List<Widget>? rows, Widget? header, double? inset}) =>
        SizedBox(
          width: 358,
          child: AppListCard(
            header: header,
            dividerInset: inset ?? 66,
            children: rows ??
                const [
                  AppListRow(key: Key('a'), title: 'Marcus Lee'),
                  AppListRow(key: Key('b'), title: 'Ashwin Pillai'),
                  AppListRow(key: Key('c'), title: 'Bryan Chua'),
                ],
          ),
        );

    testWidgets('is a clipped 20 px card on the card colour', (tester) async {
      final mode = themeModes.currentValue!;
      await _pumpUnder(tester, card(), mode: mode);
      final material = tester.widget<Material>(find
          .descendant(
              of: find.byType(AppListCard), matching: find.byType(Material))
          .first);
      expect(material.color, _paletteOf(mode).card);
      expect(material.borderRadius, BorderRadius.circular(20));
      expect(material.clipBehavior, Clip.antiAlias);
    }, variant: themeModes);

    testWidgets('draws a divider between rows only, inset 66 px',
        (tester) async {
      final mode = themeModes.currentValue!;
      await _pumpUnder(tester, card(), mode: mode);
      final dividers =
          tester.widgetList<Divider>(find.byType(Divider)).toList();
      expect(dividers, hasLength(2));
      for (final divider in dividers) {
        expect(divider.indent, 66);
        expect(divider.height, 1);
        expect(divider.color, _paletteOf(mode).line);
      }
      final firstRow = tester.getRect(find.byKey(const Key('a')));
      final firstDivider = tester.getRect(find.byType(Divider).first);
      expect(firstDivider.top, greaterThanOrEqualTo(firstRow.bottom));
      expect(tester.getTopLeft(find.byType(Divider).first).dx, 0);
    }, variant: themeModes);

    testWidgets('a single row has no divider', (tester) async {
      await _pumpUnder(tester, card(rows: const [AppListRow(title: 'Only')]));
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('a header sits above the first row without a divider',
        (tester) async {
      await _pumpUnder(
        tester,
        card(
          header: const SizedBox(key: Key('head'), height: 38),
          rows: const [AppListRow(key: Key('a'), title: 'Marcus Lee')],
        ),
      );
      expect(find.byType(Divider), findsNothing);
      expect(tester.getRect(find.byKey(const Key('head'))).bottom,
          tester.getRect(find.byKey(const Key('a'))).top);
    });

    testWidgets('the divider inset can be changed', (tester) async {
      await _pumpUnder(tester, card(inset: 14));
      expect(tester.widget<Divider>(find.byType(Divider).first).indent, 14);
    });

    testWidgets('a row is at least 62 high with 14 px side padding',
        (tester) async {
      await _pumpUnder(
          tester,
          card(rows: const [
            AppListRow(
              key: Key('a'),
              title: 'Marcus Lee',
              leading: SizedBox.square(key: Key('plate'), dimension: 40),
              trailing: SizedBox.square(key: Key('end'), dimension: 20),
            ),
          ]));
      final row = tester.getRect(find.byKey(const Key('a')));
      expect(row.height, 62);
      expect(tester.getTopLeft(find.byKey(const Key('plate'))).dx, 14);
      expect(
          row.right - tester.getTopRight(find.byKey(const Key('end'))).dx, 14);
      expect(
        tester.getTopLeft(find.text('Marcus Lee')).dx -
            tester.getTopRight(find.byKey(const Key('plate'))).dx,
        12,
      );
    });

    testWidgets('title is 16 w600 on the card text, subtitle the meta style',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pumpUnder(
        tester,
        card(rows: const [
          AppListRow(title: 'Marcus Lee', subtitle: Text('Officer Commanding')),
        ]),
        mode: mode,
      );
      final title = tester.widget<Text>(find.text('Marcus Lee')).style!;
      expect([title.fontSize, title.fontWeight], [16, FontWeight.w600]);
      expect(title.color, palette.onCard);

      final meta =
          DefaultTextStyle.of(tester.element(find.text('Officer Commanding')))
              .style;
      expect([meta.fontSize, meta.fontWeight], [13.5, FontWeight.w400]);
      expect(meta.color, palette.secondaryText);
      expect(tester.getSize(find.byType(AppListRow)).height, 62);
    }, variant: themeModes);

    testWidgets('a long title stays on one line', (tester) async {
      await _pumpUnder(
        tester,
        const SizedBox(
          width: 200,
          child: AppListCard(children: [
            AppListRow(
              title: 'Lance Corporal Muhammad Haziq Iskandar bin Abdullah',
              leading: SizedBox.square(dimension: 40),
              trailing: SizedBox.square(dimension: 48),
            ),
          ]),
        ),
      );
      expect(tester.takeException(), isNull);
      final title = tester.widget<Text>(find.textContaining('Lance Corporal'));
      expect(title.maxLines, 1);
      expect(title.overflow, TextOverflow.ellipsis);
    });

    testWidgets('onTap fires from the row and a row without one is inert',
        (tester) async {
      var taps = 0;
      await _pumpUnder(
          tester,
          card(rows: [
            AppListRow(
                key: const Key('a'), title: 'Tap me', onTap: () => taps++),
            const AppListRow(key: Key('b'), title: 'Not me'),
          ]));
      await tester.tap(find.byKey(const Key('a')));
      expect(taps, 1);
      await tester.tap(find.byKey(const Key('b')));
      expect(taps, 1);
    });

    testWidgets('a disabled row ignores taps and fades its text and leading',
        (tester) async {
      var taps = 0;
      await _pumpUnder(
          tester,
          card(rows: [
            AppListRow(
              key: const Key('a'),
              title: 'Ineligible',
              enabled: false,
              onTap: () => taps++,
              leading: const SizedBox.square(key: Key('plate'), dimension: 40),
              trailing: const Icon(Icons.check_circle_rounded),
            ),
          ]));
      await tester.tap(find.byKey(const Key('a')));
      expect(taps, 0);
      final faded = tester.widgetList<Opacity>(find.descendant(
          of: find.byKey(const Key('a')), matching: find.byType(Opacity)));
      expect(faded.map((o) => o.opacity), [0.45, 0.45]);
      expect(
        find.ancestor(
            of: find.byIcon(Icons.check_circle_rounded),
            matching: find.byType(Opacity)),
        findsNothing,
      );
    });

    testWidgets('an enabled row adds no opacity layers', (tester) async {
      await _pumpUnder(tester, card());
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('a dimmed row fades like a disabled one but takes taps',
        (tester) async {
      var taps = 0;
      await _pumpUnder(
          tester,
          card(rows: [
            AppListRow(
              key: const Key('a'),
              title: 'Ineligible',
              dimmed: true,
              onTap: () => taps++,
              leading: const SizedBox.square(dimension: 40),
              trailing: const Icon(Icons.check_circle_rounded),
            ),
          ]));
      await tester.tap(find.byKey(const Key('a')));
      expect(taps, 1);
      final faded = tester.widgetList<Opacity>(find.descendant(
          of: find.byKey(const Key('a')), matching: find.byType(Opacity)));
      expect(faded.map((o) => o.opacity), [0.45, 0.45]);
    });

    testWidgets('the card colour can be replaced', (tester) async {
      final mode = themeModes.currentValue!;
      await _pumpUnder(
        tester,
        const SizedBox(
          width: 358,
          child: AppListCard(color: Color(0xFF123456), children: [
            AppListRow(title: 'Marcus Lee'),
          ]),
        ),
        mode: mode,
      );
      final material = tester.widget<Material>(find
          .descendant(
              of: find.byType(AppListCard), matching: find.byType(Material))
          .first);
      expect(material.color, const Color(0xFF123456));
      await _pumpUnder(tester, card(), mode: mode);
      final plain = tester.widget<Material>(find
          .descendant(
              of: find.byType(AppListCard), matching: find.byType(Material))
          .first);
      expect(plain.color, _paletteOf(mode).card);
    }, variant: themeModes);
  });

  group('DateHeader', () {
    final today = DateTime(2026, 10, 8);

    Widget header({
      DateTime? date,
      VoidCallback? onPick,
      Widget? action,
      Key? pickerKey,
    }) =>
        SizedBox(
          width: 390,
          child: DateHeader(
            date: date ?? today,
            today: today,
            onPickDate: onPick ?? () {},
            pickerKey: pickerKey,
            action: action,
          ),
        );

    testWidgets('shows the long date over Today', (tester) async {
      await _pumpUnder(tester, header(date: DateTime(2026, 10, 8, 14)));
      expect(find.text('October 8, 2026'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('any other day shows its weekday', (tester) async {
      await _pumpUnder(tester, header(date: DateTime(2026, 10, 9)));
      expect(find.text('October 9, 2026'), findsOneWidget);
      expect(find.text('Friday'), findsOneWidget);
      expect(find.text('Today'), findsNothing);
    });

    testWidgets('the label is 28 bold, the date 14 in the secondary colour',
        (tester) async {
      final mode = themeModes.currentValue!;
      await _pumpUnder(tester, header(), mode: mode);
      final label = tester.widget<Text>(find.text('Today')).style!;
      expect([label.fontSize, label.fontWeight], [28, FontWeight.bold]);
      final date = tester.widget<Text>(find.text('October 8, 2026')).style!;
      expect(date.fontSize, 14);
      expect(date.color, _paletteOf(mode).secondaryText);
    }, variant: themeModes);

    testWidgets('the picker is a 48 px card2 square with a 14 px radius',
        (tester) async {
      final mode = themeModes.currentValue!;
      await _pumpUnder(tester, header(pickerKey: const Key('pick')),
          mode: mode);
      expect(tester.getSize(find.byKey(const Key('pick'))), const Size(48, 48));
      final button = tester.widget<IconButton>(find.byKey(const Key('pick')));
      expect(button.style!.backgroundColor!.resolve({}),
          _paletteOf(mode).cardElevated);
      expect(
        button.style!.shape!.resolve({}),
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    }, variant: themeModes);

    testWidgets('tapping the picker calls onPickDate', (tester) async {
      var picks = 0;
      await _pumpUnder(
          tester, header(pickerKey: const Key('pick'), onPick: () => picks++));
      await tester.tap(find.byKey(const Key('pick')));
      expect(picks, 1);
    });

    testWidgets('has no action unless given one', (tester) async {
      await _pumpUnder(tester, header());
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('an action sits at the right edge, 16 px in', (tester) async {
      await _pumpUnder(
        tester,
        header(
          action: TextButton(
              key: const Key('add'),
              onPressed: () {},
              child: const Text('Add')),
        ),
      );
      final add = tester.getRect(find.byKey(const Key('add')));
      expect(add.right, 390 - 16);
      expect(tester.getTopLeft(find.byType(IconButton)).dx, 16);
    });

    testWidgets('a wide action leaves the date room, no overflow',
        (tester) async {
      await _pumpUnder(
        tester,
        header(
          action:
              FilledButton(onPressed: () {}, child: const Text('Add Conduct')),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Today'), findsOneWidget);
    });
  });

  group('SectionHeader', () {
    testWidgets('title is h3: 16 w600 on the card text colour', (tester) async {
      final mode = themeModes.currentValue!;
      await _pumpUnder(tester, const SectionHeader('Past Statuses'),
          mode: mode);
      final title = tester.widget<Text>(find.text('Past Statuses')).style!;
      expect([title.fontSize, title.fontWeight], [16, FontWeight.w600]);
      expect(title.color, _paletteOf(mode).onCard);
    }, variant: themeModes);

    testWidgets('caption is 13 regular in the secondary colour on the right',
        (tester) async {
      final mode = themeModes.currentValue!;
      await _pumpUnder(
          tester,
          const SizedBox(
              width: 390, child: SectionHeader('Past', caption: '3 today')),
          mode: mode);
      final caption = tester.widget<Text>(find.text('3 today')).style!;
      expect([caption.fontSize, caption.fontWeight], [13, FontWeight.w400]);
      expect(caption.color, _paletteOf(mode).secondaryText);
      expect(caption.fontFeatures, [const FontFeature.tabularFigures()]);
      expect(tester.getTopRight(find.text('3 today')).dx, 390 - 20);
      expect(tester.getTopLeft(find.text('Past')).dx, 20);
    }, variant: themeModes);

    testWidgets('no caption means no second text', (tester) async {
      await _pumpUnder(tester, const SectionHeader('Past'));
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('title and caption share a baseline', (tester) async {
      await _pumpUnder(
          tester,
          const SizedBox(
              width: 390, child: SectionHeader('Past', caption: '3')));
      final title = tester.getRect(find.text('Past'));
      final caption = tester.getRect(find.text('3'));
      expect(caption.bottom, lessThanOrEqualTo(title.bottom + 1));
      expect(caption.bottom, greaterThan(title.bottom - 6));
    });

    testWidgets('default spacing is 28 above, 10 below, 20 each side',
        (tester) async {
      await _pumpUnder(tester, const SectionHeader('Past'));
      final box = tester.getRect(find.byType(SectionHeader));
      final text = tester.getRect(find.text('Past'));
      expect(text.left - box.left, 20);
      expect(text.top - box.top, 28);
      expect(box.bottom - text.bottom, 10);
    });

    testWidgets('padding can be overridden', (tester) async {
      await _pumpUnder(
          tester,
          const SectionHeader('Past',
              padding: EdgeInsets.symmetric(horizontal: 4)));
      final box = tester.getRect(find.byType(SectionHeader));
      final text = tester.getRect(find.text('Past'));
      expect(text.left - box.left, 4);
      expect(text.top, box.top);
    });

    testWidgets('is a header in semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpUnder(tester, const SectionHeader('Past'));
      expect(tester.getSemantics(find.text('Past')),
          isSemantics(label: 'Past', isHeader: true));
      handle.dispose();
    });

    testWidgets('a long title wraps beside the caption without overflow',
        (tester) async {
      await _pumpUnder(
          tester,
          const SizedBox(
              width: 150,
              child: SectionHeader('Conducts Completed / Ongoing',
                  caption: '3 today')));
      expect(tester.takeException(), isNull);
    });
  });

  group('PageTitle', () {
    for (final mode in ThemeMode.values.where((m) => m != ThemeMode.system)) {
      testWidgets('is a 24 w600 app bar row in the ${mode.name} theme',
          (tester) async {
        await _pumpUnder(tester, const PageTitle('Guard Duty'), mode: mode);
        final style = tester.widget<Text>(find.text('Guard Duty')).style!;
        expect([style.fontSize, style.fontWeight], [24, FontWeight.w600]);
        expect(style.color,
            tester.element(find.byType(PageTitle)).colors.onSurface);
        expect(tester.getSize(find.byType(PageTitle)).height,
            AppLayout.appBarHeight);
        expect(tester.getTopLeft(find.text('Guard Duty')).dx, 20);
      });
    }

    testWidgets('a long title stays on one line', (tester) async {
      await _pumpUnder(
          tester,
          const SizedBox(
              width: 120, child: PageTitle('A very long page title here')));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(PageTitle)).height,
          AppLayout.appBarHeight);
    });
  });
}

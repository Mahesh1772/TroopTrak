import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/state_tone.dart';
import 'package:trooptrak_final_application/core/widgets/tally_strip.dart';

import '../../helpers/pump_app.dart';

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

List<TallyTick> _ticks(int count, [StateTone tone = StateTone.inCamp]) =>
    [for (var i = 0; i < count; i++) TallyTick(tone: tone)];

Finder _tick(int group, int index) =>
    find.byKey(ValueKey('tick-$group-$index'));

Finder _ring(int group, int index) =>
    find.byKey(ValueKey('tick-$group-$index-self'));

Finder _body(Finder tick) =>
    find.descendant(of: tick, matching: find.byType(DecoratedBox)).first;

BoxDecoration _decorationOf(Finder box, WidgetTester tester) =>
    tester.widget<DecoratedBox>(box).decoration as BoxDecoration;

/// What the tick is animating towards.
BoxDecoration _target(WidgetTester tester, int group, int index) =>
    tester.widget<AnimatedContainer>(_tick(group, index)).decoration!
        as BoxDecoration;

/// What is on screen right now, mid-animation included.
BoxDecoration _drawn(WidgetTester tester, int group, int index) =>
    _decorationOf(_body(_tick(group, index)), tester);

/// Includes the Y scale, which `getSize` (layout size) never sees.
double _paintedHeight(WidgetTester tester, Finder box) =>
    tester.getBottomLeft(box).dy - tester.getTopLeft(box).dy;

double _opacity(WidgetTester tester, int group, int index) => tester
    .renderObject<RenderAnimatedOpacity>(find.ancestor(
      of: _tick(group, index),
      matching: find.byType(AnimatedOpacity),
    ))
    .opacity
    .value;

({double left, double right}) _span(
  WidgetTester tester,
  int group,
  int count,
) =>
    (
      left: tester.getTopLeft(_tick(group, 0)).dx,
      right: tester.getTopRight(_tick(group, count - 1)).dx,
    );

double _width(({double left, double right}) span) => span.right - span.left;

Future<void> _pumpStrip(
  WidgetTester tester,
  TallyStrip strip, {
  ThemeMode mode = ThemeMode.dark,
  double width = 390,
}) =>
    tester.pumpThemed(
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: strip),
      ),
      mode: mode,
    );

Future<void> _pumpCentered(WidgetTester tester, TallyStrip strip) =>
    tester.pumpThemed(Center(child: strip));

Future<void> _loadFonts(WidgetTester tester) => tester.runAsync(() async {
      GoogleFonts.barlow(fontWeight: FontWeight.w400);
      GoogleFonts.barlowCondensed(fontWeight: FontWeight.w600);
      await GoogleFonts.pendingFonts();
    });

Future<void> _letTooltipGo(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future<void> _showTooltipOn(WidgetTester tester, Finder tick) async {
  await tester.longPress(tick);
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  group('layout', () {
    testWidgets('group widths follow tick counts, 10 px apart', (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(ticks: _ticks(10)),
          TallyGroup(ticks: _ticks(30)),
        ]),
      );
      final first = _span(tester, 0, 10);
      final second = _span(tester, 1, 30);

      expect(first.left, 0);
      expect(_width(first), moreOrLessEquals(95));
      expect(second.left - first.right, moreOrLessEquals(10));
      expect(_width(second), moreOrLessEquals(285));
      expect(second.right, moreOrLessEquals(390));
    });

    testWidgets('ticks are 2 px apart, 36 high and fill the group',
        (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [TallyGroup(ticks: _ticks(5))]),
      );

      for (var i = 0; i < 4; i++) {
        expect(
          tester.getTopLeft(_tick(0, i + 1)).dx -
              tester.getTopRight(_tick(0, i)).dx,
          moreOrLessEquals(2),
        );
      }
      expect(tester.getSize(_tick(0, 0)).height, 36);
      expect(tester.getSize(_tick(0, 0)).width, moreOrLessEquals(382 / 5));
      expect(_span(tester, 0, 5).right, moreOrLessEquals(390));
    });

    testWidgets('the tick height is a parameter', (tester) async {
      for (final height in [18.0, 26.0, 46.0]) {
        await _pumpStrip(
          tester,
          TallyStrip(
            tickHeight: height,
            groups: [TallyGroup(ticks: _ticks(3))],
          ),
        );
        expect(tester.getSize(_tick(0, 1)).height, height);
      }
    });

    testWidgets('a labelled group never gets less than 86 px', (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(label: 'Officers', figure: '4/5', ticks: _ticks(5)),
          TallyGroup(label: 'WOSEs', figure: '28/37', ticks: _ticks(37)),
        ]),
        width: 308,
      );
      final officers = _span(tester, 0, 5);
      final woses = _span(tester, 1, 37);

      expect(_width(officers), moreOrLessEquals(86));
      expect(woses.left - officers.right, moreOrLessEquals(10));
      expect(_width(woses), moreOrLessEquals(212));
      expect(tester.getSize(_tick(1, 0)).width, moreOrLessEquals(140 / 37));
    });

    testWidgets('unlabelled groups share the width purely by tick count',
        (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(ticks: _ticks(5)),
          TallyGroup(ticks: _ticks(37)),
        ]),
        width: 308,
      );

      expect(_width(_span(tester, 0, 5)), moreOrLessEquals(298 * 5 / 42));
    });

    testWidgets('several cramped labelled groups are pinned in turn',
        (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(label: 'A', ticks: _ticks(2)),
          TallyGroup(label: 'B', ticks: _ticks(2)),
          TallyGroup(label: 'C', ticks: _ticks(36)),
        ]),
      );

      expect(_width(_span(tester, 0, 2)), moreOrLessEquals(86));
      expect(_width(_span(tester, 1, 2)), moreOrLessEquals(86));
      expect(_width(_span(tester, 2, 36)), moreOrLessEquals(198));
    });

    testWidgets('the 86 px floor is dropped when it cannot fit',
        (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(label: 'A', ticks: _ticks(1)),
          TallyGroup(label: 'B', ticks: _ticks(3)),
        ]),
        width: 100,
      );

      expect(tester.takeException(), isNull);
      expect(_span(tester, 1, 3).right, moreOrLessEquals(100));
    });

    testWidgets('an empty group counts as one tick and breaks nothing',
        (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          const TallyGroup(label: 'None', figure: '0', ticks: []),
          TallyGroup(ticks: _ticks(3)),
        ]),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('None'), findsOneWidget);
      expect(_tick(0, 0), findsNothing);
      expect(_span(tester, 1, 3).left, moreOrLessEquals(95 + 10));
    });

    testWidgets('a strip without groups renders nothing', (tester) async {
      await _pumpStrip(tester, const TallyStrip(groups: []));

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(TallyStrip)).height, 0);
    });

    testWidgets('42 and 31 ticks fit with no overflow', (tester) async {
      for (final width in [390.0, 330.0, 322.0]) {
        for (final strip in [
          TallyStrip(groups: [
            TallyGroup(
                label: 'Booked in', figure: '31 / 41', ticks: _ticks(42)),
          ]),
          TallyStrip(
            onGradient: true,
            groups: [
              TallyGroup(
                label: 'October in camp',
                figure: '7 of 31 days',
                ticks: _ticks(31),
              ),
            ],
          ),
          TallyStrip(groups: [
            TallyGroup(label: 'Officers', figure: '4/5', ticks: _ticks(5)),
            TallyGroup(label: 'WOSEs', figure: '28/37', ticks: _ticks(37)),
          ]),
        ]) {
          await _pumpStrip(tester, strip, width: width);

          expect(tester.takeException(), isNull, reason: '$width');
          expect(tester.getSize(find.byType(TallyStrip)).width, width);
          for (var g = 0; g < strip.groups.length; g++) {
            final last = strip.groups[g].ticks.length - 1;
            expect(
              tester.getTopRight(_tick(g, last)).dx,
              lessThanOrEqualTo(width + 0.001),
            );
            expect(tester.getSize(_tick(g, 0)).width, greaterThanOrEqualTo(2));
          }
        }
      }
    });

    testWidgets('no width produces a rounding overflow', (tester) async {
      final groups = [
        TallyGroup(label: 'Officers', figure: '4/5', ticks: _ticks(5)),
        TallyGroup(label: 'WOSEs', figure: '28/37', ticks: _ticks(37)),
        TallyGroup(ticks: _ticks(11)),
      ];
      for (var width = 240.3; width < 520; width += 17.9) {
        await _pumpStrip(tester, TallyStrip(groups: groups), width: width);
        expect(tester.takeException(), isNull, reason: 'width $width');
      }
    });

    testWidgets('a crowded group closes its gaps before ticks drop under 2 px',
        (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [TallyGroup(ticks: _ticks(150))]),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(_tick(0, 0)).width, moreOrLessEquals(2));
      expect(tester.getSize(_tick(0, 149)).width, moreOrLessEquals(2));
      expect(_span(tester, 0, 150).right, moreOrLessEquals(390));
    });

    testWidgets('every tick is keyed by its group and index', (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(ticks: _ticks(3)),
          TallyGroup(ticks: _ticks(2)),
        ]),
      );

      for (final (group, count) in [(0, 3), (1, 2)]) {
        for (var i = 0; i < count; i++) {
          expect(_tick(group, i), findsOneWidget);
        }
        expect(_tick(group, count), findsNothing);
      }
    });
  });

  group('label row', () {
    testWidgets('shows the label left and the figure right, 8 px above',
        (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(label: 'Officers', figure: '4/5', ticks: _ticks(5)),
        ]),
      );

      expect(find.text('Officers'), findsOneWidget);
      expect(find.text('4/5'), findsOneWidget);
      final row = find
          .ancestor(of: find.text('Officers'), matching: find.byType(Row))
          .first;
      expect(tester.getTopLeft(row).dy, 0);
      expect(
        tester.getTopLeft(_tick(0, 0)).dy - tester.getBottomLeft(row).dy,
        moreOrLessEquals(8),
      );
      expect(
        tester.getTopLeft(find.text('Officers')).dx,
        lessThan(tester.getTopLeft(find.text('4/5')).dx),
      );
      expect(tester.getTopRight(find.text('4/5')).dx, moreOrLessEquals(390));
    });

    testWidgets('has no row at all without a label', (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [TallyGroup(figure: '9', ticks: _ticks(3))]),
      );

      expect(find.byType(Text), findsNothing);
      expect(tester.getTopLeft(_tick(0, 0)).dy, 0);
    });

    testWidgets('a label without a figure shows only the label',
        (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [TallyGroup(label: 'Added', ticks: _ticks(3))]),
      );

      expect(find.byType(Text), findsOneWidget);
      expect(find.text('Added'), findsOneWidget);
    });

    testWidgets('label is a 13 px caption, figure a 15 px tabular figure',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(label: 'Booked in', figure: '31 / 41', ticks: _ticks(3)),
        ]),
        mode: mode,
      );

      final label = tester.widget<Text>(find.text('Booked in')).style!;
      expect(label.fontFamily, startsWith('Barlow_'));
      expect([label.fontSize, label.fontWeight], [13, FontWeight.w400]);
      expect(label.color, palette.secondaryText);

      final figure = tester.widget<Text>(find.text('31 / 41')).style!;
      expect(figure.fontFamily, startsWith('BarlowCondensed_'));
      expect([figure.fontSize, figure.fontWeight], [15, FontWeight.w600]);
      expect(figure.color, palette.onCard);
      expect(figure.letterSpacing, moreOrLessEquals(0.3));
      expect(figure.fontFeatures, [const FontFeature.tabularFigures()]);
    }, variant: themeModes);

    testWidgets('a long label is cut and the figure keeps its place',
        (tester) async {
      await _loadFonts(tester);
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(
            label: 'Participation strength',
            figure: '27 / 42',
            ticks: _ticks(10),
          ),
        ]),
        width: 108,
      );

      expect(tester.takeException(), isNull);
      expect(
        tester
            .renderObject<RenderParagraph>(find.text('Participation strength'))
            .didExceedMaxLines,
        isTrue,
      );
      expect(
        tester.getTopRight(find.text('27 / 42')).dx,
        moreOrLessEquals(108),
      );
    });

    testWidgets('Officers 4/5 fits the 86 px group in Barlow', (tester) async {
      await _loadFonts(tester);
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(label: 'Officers', figure: '4/5', ticks: _ticks(5)),
          TallyGroup(label: 'WOSEs', figure: '28/37', ticks: _ticks(37)),
        ]),
        width: 308,
      );

      for (final text in ['Officers', '4/5', 'WOSEs', '28/37']) {
        expect(
          tester
              .renderObject<RenderParagraph>(find.text(text))
              .didExceedMaxLines,
          isFalse,
          reason: text,
        );
      }
    });
  });

  group('tick style', () {
    testWidgets('each tone is filled from the palette, radius 2',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      final expected = {
        StateTone.inCamp: palette.success,
        StateTone.excuse: palette.statusExcuse,
        StateTone.leave: palette.statusLeave,
        StateTone.medical: palette.statusMedical,
        StateTone.out: palette.tickOff,
        StateTone.accent: palette.accent,
      };
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(ticks: [
            for (final tone in expected.keys) TallyTick(tone: tone),
          ]),
        ]),
        mode: mode,
      );

      var i = 0;
      for (final fill in expected.values) {
        final decoration = _target(tester, 0, i);
        expect(decoration.color, fill, reason: 'tick $i');
        expect(decoration.border, isNull);
        expect(decoration.borderRadius, BorderRadius.circular(2));
        expect(_drawn(tester, 0, i).color, fill);
        i++;
      }
    }, variant: themeModes);

    testWidgets('the tone colours are the mockup values', (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(groups: [
          TallyGroup(ticks: [
            for (final tone in StateTone.values) TallyTick(tone: tone),
          ]),
        ]),
      );

      expect(_target(tester, 0, 0).color, const Color(0xFF4CAF50));
      expect(_target(tester, 0, 1).color, const Color(0xFFFF6F00));
      expect(_target(tester, 0, 2).color, const Color(0xFFF44336));
      expect(_target(tester, 0, 3).color, const Color(0xFF1E88E5));
      expect(_target(tester, 0, 4).color, const Color(0x21FFFFFF));
      expect(_target(tester, 0, 5).color, const Color(0xFF8147E6));
    });

    testWidgets('a future tick is faint with a 1 px line border',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pumpStrip(
        tester,
        const TallyStrip(groups: [
          TallyGroup(ticks: [
            TallyTick(tone: StateTone.out),
            TallyTick.future(),
          ]),
        ]),
        mode: mode,
      );

      final future = _target(tester, 0, 1);
      expect(future.color, palette.tickFuture);
      expect(future.border, Border.all(color: palette.line));
      expect(future.borderRadius, BorderRadius.circular(2));
      expect(_target(tester, 0, 0).border, isNull);
      expect(tester.getSize(_tick(0, 1)), tester.getSize(_tick(0, 0)));
    }, variant: themeModes);

    testWidgets('a tone change fades over 250 ms', (tester) async {
      late StateSetter rebuild;
      var tone = StateTone.out;
      await tester.pumpThemed(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return TallyStrip(groups: [
              TallyGroup(ticks: [TallyTick(tone: tone)]),
            ]);
          },
        ),
      );
      expect(_drawn(tester, 0, 0).color, AppPalette.dark.tickOff);

      rebuild(() => tone = StateTone.inCamp);
      await tester.pump();
      expect(_drawn(tester, 0, 0).color, AppPalette.dark.tickOff);

      await tester.pump(const Duration(milliseconds: 40));
      final midway = _drawn(tester, 0, 0).color;
      expect(midway, isNot(AppPalette.dark.tickOff));
      expect(midway, isNot(AppPalette.dark.success));

      await tester.pump(const Duration(milliseconds: 250));
      expect(_drawn(tester, 0, 0).color, AppPalette.dark.success);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('on gradient', () {
    testWidgets('uses the light-on-purple tick colours and white text',
        (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(
          onGradient: true,
          groups: [
            TallyGroup(
              label: 'October in camp',
              figure: '7 of 8 days',
              ticks: [
                for (final tone in StateTone.values) TallyTick(tone: tone),
                const TallyTick(tone: StateTone.inCamp, isSelf: true),
                const TallyTick.future(),
              ],
            ),
          ],
        ),
        mode: themeModes.currentValue!,
      );

      expect(
        [for (var i = 0; i < 8; i++) _target(tester, 0, i).color],
        const [
          Color(0xFF7EE07F),
          Color(0xFFFFA84D),
          Color(0xFFFF8A80),
          Color(0xFF82C4FF),
          Color(0x33FFFFFF),
          Color(0xFFFFFFFF),
          Color(0xFF7EE07F),
          Color(0x12FFFFFF),
        ],
      );
      expect(_target(tester, 0, 7).border, isNull);

      final ring = _decorationOf(_ring(0, 6), tester);
      expect((ring.border! as Border).top.color, AppColors.white);

      final label = tester.widget<Text>(find.text('October in camp')).style!;
      expect(label.color, const Color(0xCCFFFFFF));
      expect(
        tester.widget<Text>(find.text('7 of 8 days')).style!.color,
        AppColors.white,
      );
    }, variant: themeModes);

    testWidgets('looks the same in light and dark', (tester) async {
      Future<List<Color?>> fills(ThemeMode mode) async {
        await _pumpStrip(
          tester,
          TallyStrip(
            onGradient: true,
            groups: [
              TallyGroup(ticks: [
                for (final tone in StateTone.values) TallyTick(tone: tone),
              ]),
            ],
          ),
          mode: mode,
        );
        return [for (var i = 0; i < 6; i++) _target(tester, 0, i).color];
      }

      expect(await fills(ThemeMode.light), await fills(ThemeMode.dark));
    });
  });

  group('self tick', () {
    testWidgets('only the self tick has a 1.5 px onCard ring', (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pumpStrip(
        tester,
        const TallyStrip(groups: [
          TallyGroup(ticks: [
            TallyTick(tone: StateTone.accent),
            TallyTick(tone: StateTone.accent, isSelf: true),
            TallyTick(tone: StateTone.accent),
          ]),
        ]),
        mode: mode,
      );

      expect(_ring(0, 0), findsNothing);
      expect(_ring(0, 1), findsOneWidget);
      expect(_ring(0, 2), findsNothing);
      final side = (_decorationOf(_ring(0, 1), tester).border! as Border).top;
      expect([side.color, side.width], [palette.onCard, 1.5]);
    }, variant: themeModes);

    testWidgets('the ring sits 1 px off the tick and outside its box',
        (tester) async {
      await _pumpStrip(
        tester,
        const TallyStrip(groups: [
          TallyGroup(ticks: [
            TallyTick(tone: StateTone.accent),
            TallyTick(tone: StateTone.accent, isSelf: true),
          ]),
        ]),
      );

      expect(
        tester.getRect(_ring(0, 1)),
        rectMoreOrLessEquals(tester.getRect(_tick(0, 1)).inflate(2.5)),
      );
    });

    testWidgets('the ring changes neither the size nor the place of any tick',
        (tester) async {
      Future<List<Rect>> rects({required bool withSelf}) async {
        await _pumpStrip(
          tester,
          TallyStrip(groups: [
            TallyGroup(label: 'You', figure: '1', ticks: [
              const TallyTick(tone: StateTone.accent),
              TallyTick(tone: StateTone.accent, isSelf: withSelf),
              const TallyTick(tone: StateTone.accent),
            ]),
          ]),
        );
        return [for (var i = 0; i < 3; i++) tester.getRect(_tick(0, i))];
      }

      final plain = await rects(withSelf: false);
      final marked = await rects(withSelf: true);

      expect(marked, plain);
      expect(tester.takeException(), isNull);
    });
  });

  group('highlight', () {
    const groups = [
      TallyGroup(ticks: [
        TallyTick(tone: StateTone.inCamp),
        TallyTick(tone: StateTone.leave),
        TallyTick(tone: StateTone.inCamp),
      ]),
      TallyGroup(ticks: [
        TallyTick(tone: StateTone.inCamp),
        TallyTick(tone: StateTone.out),
      ]),
    ];
    const all = [(0, 0), (0, 1), (0, 2), (1, 0), (1, 1)];

    Future<void> pumpWith(
      WidgetTester tester,
      bool Function(int, TallyTick)? highlight,
    ) =>
        _pumpStrip(tester, TallyStrip(groups: groups, highlight: highlight));

    testWidgets('matching ticks grow 1.18 on Y and the rest fade to 35%',
        (tester) async {
      await pumpWith(tester, null);
      final resting = {
        for (final (g, i) in all) (g, i): tester.getRect(_tick(g, i)),
      };

      await pumpWith(
        tester,
        (group, tick) => group == 0 && tick.tone == StateTone.inCamp,
      );
      await tester.pumpAndSettle();

      for (final (g, i) in all) {
        final body = _body(_tick(g, i));
        final grown = g == 0 && i != 1;
        expect(
          _paintedHeight(tester, body),
          moreOrLessEquals(grown ? 36 * 1.18 : 36),
          reason: 'tick $g-$i',
        );
        expect(
          _opacity(tester, g, i),
          moreOrLessEquals(grown ? 1 : 0.35),
          reason: 'tick $g-$i',
        );
        expect(tester.getRect(_tick(g, i)), resting[(g, i)]);
      }
      final grownBody = _body(_tick(0, 0));
      expect(
        (tester.getTopLeft(grownBody).dy + tester.getBottomLeft(grownBody).dy) /
            2,
        moreOrLessEquals(18),
      );
    });

    testWidgets('without a predicate nothing grows and nothing fades',
        (tester) async {
      await pumpWith(tester, null);
      await tester.pumpAndSettle();

      for (final (g, i) in all) {
        expect(_paintedHeight(tester, _body(_tick(g, i))), 36);
        expect(_opacity(tester, g, i), 1);
      }
    });

    testWidgets('the change is animated and clearing the predicate undoes it',
        (tester) async {
      late StateSetter rebuild;
      bool Function(int, TallyTick)? predicate;
      await tester.pumpThemed(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return TallyStrip(groups: groups, highlight: predicate);
          },
        ),
      );
      final grower = _body(_tick(1, 0));

      rebuild(() => predicate = (group, tick) => group == 1);
      await tester.pump();
      expect(_opacity(tester, 0, 0), 1);
      expect(_paintedHeight(tester, grower), 36);

      await tester.pump(const Duration(milliseconds: 30));
      expect(_opacity(tester, 0, 0), allOf(lessThan(1), greaterThan(0.35)));
      expect(
        _paintedHeight(tester, grower),
        allOf(greaterThan(36), lessThan(36 * 1.18)),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(_opacity(tester, 0, 0), moreOrLessEquals(0.35));
      expect(_opacity(tester, 1, 1), 1);
      expect(_paintedHeight(tester, grower), moreOrLessEquals(36 * 1.18));

      rebuild(() => predicate = null);
      await tester.pumpAndSettle();
      expect(_opacity(tester, 0, 0), 1);
      expect(_paintedHeight(tester, grower), 36);
    });

    testWidgets('the predicate is asked about every tick with its group',
        (tester) async {
      final asked = <(int, TallyTick)>[];
      await pumpWith(tester, (group, tick) {
        asked.add((group, tick));
        return true;
      });

      expect(asked, hasLength(all.length));
      for (final (g, i) in all) {
        expect(asked, contains((g, groups[g].ticks[i])));
      }
    });

    testWidgets('a highlighted self tick grows with its ring', (tester) async {
      await _pumpStrip(
        tester,
        TallyStrip(
          groups: const [
            TallyGroup(ticks: [
              TallyTick(tone: StateTone.accent, isSelf: true),
              TallyTick(tone: StateTone.accent),
            ]),
          ],
          highlight: (group, tick) => tick.isSelf,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        _paintedHeight(tester, _ring(0, 0)),
        moreOrLessEquals((36 + 5) * 1.18),
      );
      expect(_opacity(tester, 0, 0), 1);
      expect(_opacity(tester, 0, 1), moreOrLessEquals(0.35));
    });
  });

  group('tooltip', () {
    TallyStrip strip({String? title, String? detail}) => TallyStrip(groups: [
          TallyGroup(ticks: [
            const TallyTick(tone: StateTone.out),
            TallyTick(tone: StateTone.inCamp, title: title, detail: detail),
            const TallyTick(tone: StateTone.out),
          ]),
        ]);

    testWidgets('a long press shows the title and the muted detail',
        (tester) async {
      await _pumpCentered(
        tester,
        strip(title: 'CPT Marcus Lee', detail: 'In camp'),
      );
      expect(find.text('CPT Marcus Lee · In camp'), findsNothing);

      await _showTooltipOn(tester, _tick(0, 1));

      final message = find.text('CPT Marcus Lee · In camp');
      expect(message, findsOneWidget);
      final text = tester.widget<Text>(message);
      final span = text.textSpan! as TextSpan;
      expect(span.text, 'CPT Marcus Lee');
      expect(span.style, isNull);
      final detail = span.children!.single as TextSpan;
      expect(detail.text, ' · In camp');
      expect(detail.style!.color, AppColors.tooltipDetail);
      expect(text.style!.color, AppColors.white);
      expect(text.style!.fontWeight, FontWeight.w500);
      expect(text.style!.fontSize, 13);

      final box = tester.widget<Container>(
        find.ancestor(of: message, matching: find.byType(Container)).first,
      );
      expect(
        (box.decoration! as BoxDecoration).color,
        AppColors.tooltipBackground,
      );
      await _letTooltipGo(tester);
    });

    testWidgets('the tooltip floats 6 px above the tick, centred on it',
        (tester) async {
      await _pumpCentered(tester, strip(title: 'CPT Marcus Lee'));

      await _showTooltipOn(tester, _tick(0, 1));

      final box = find
          .ancestor(
            of: find.text('CPT Marcus Lee'),
            matching: find.byType(Container),
          )
          .first;
      final tick = tester.getRect(_tick(0, 1));
      expect(tester.getBottomLeft(box).dy, moreOrLessEquals(tick.top - 6));
      expect(tester.getCenter(box).dx, moreOrLessEquals(tick.center.dx));
      await _letTooltipGo(tester);
    });

    testWidgets('a title alone shows no separator', (tester) async {
      await _pumpCentered(tester, strip(title: 'CPT Marcus Lee'));

      await _showTooltipOn(tester, _tick(0, 1));

      final text = tester.widget<Text>(find.text('CPT Marcus Lee'));
      expect((text.textSpan! as TextSpan).children, isEmpty);
      await _letTooltipGo(tester);
    });

    testWidgets('the self tick shows its tooltip through the ring layer',
        (tester) async {
      await _pumpCentered(
        tester,
        const TallyStrip(groups: [
          TallyGroup(ticks: [
            TallyTick(tone: StateTone.accent),
            TallyTick(
              tone: StateTone.accent,
              isSelf: true,
              title: 'CFC Tan Wei Jie',
              detail: 'participating',
            ),
          ]),
        ]),
      );

      await _showTooltipOn(tester, _tick(0, 1));

      expect(find.text('CFC Tan Wei Jie · participating'), findsOneWidget);
      await _letTooltipGo(tester);
    });

    testWidgets('a tap does not show it', (tester) async {
      await _pumpCentered(
        tester,
        strip(title: 'CPT Marcus Lee', detail: 'In camp'),
      );

      await tester.tap(_tick(0, 1));
      for (final wait in [200, 400, 600]) {
        await tester.pump(Duration(milliseconds: wait));
        expect(
          find.textContaining('Marcus', findRichText: true),
          findsNothing,
          reason: 'nothing may show while a tap tooltip would still be up',
        );
      }
    });

    testWidgets('it goes away after the finger lifts', (tester) async {
      await _pumpCentered(tester, strip(title: 'CPT Marcus Lee'));

      await _showTooltipOn(tester, _tick(0, 1));
      expect(find.text('CPT Marcus Lee'), findsOneWidget);

      await _letTooltipGo(tester);
      expect(find.text('CPT Marcus Lee'), findsNothing);
    });

    testWidgets('a tick without a title has no tooltip at all', (tester) async {
      await _pumpCentered(tester, strip());

      expect(find.byType(Tooltip), findsNothing);
      await tester.longPress(_tick(0, 1));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      expect(find.byType(RichText), findsNothing);
    });

    testWidgets('only titled ticks are wrapped, long press, above',
        (tester) async {
      await _pumpCentered(tester, strip(title: 'CPT Marcus Lee'));

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.triggerMode, TooltipTriggerMode.longPress);
      expect(tooltip.preferBelow, isFalse);
      expect(find.byType(Tooltip), findsOneWidget);
      expect(
        find.descendant(of: find.byType(Tooltip), matching: _tick(0, 1)),
        findsOneWidget,
      );
    });
  });
}

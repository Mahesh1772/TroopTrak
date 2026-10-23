import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/app_sheet.dart';

import '../../helpers/pump_app.dart';

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

Future<void> _open(
  WidgetTester tester, {
  required WidgetBuilder builder,
  ThemeMode mode = ThemeMode.dark,
  void Function(Future<Object?> result)? onOpened,
}) async {
  await tester.pumpThemed(
    Builder(
      builder: (context) => TextButton(
        onPressed: () {
          final result = showAppSheet<Object>(
            context: context,
            builder: builder,
          );
          onOpened?.call(result);
        },
        child: const Text('open'),
      ),
    ),
    mode: mode,
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Widget _content(BuildContext context) =>
    const SizedBox(key: Key('content'), height: 100, child: Text('hello'));

Finder get _sheet => find.byType(BottomSheet);

void main() {
  group('frame', () {
    testWidgets('shows the content on the sheet colour with 28 px top corners',
        (tester) async {
      final mode = themeModes.currentValue!;
      await _open(tester, builder: _content, mode: mode);

      expect(find.text('hello'), findsOneWidget);
      final material = tester.widget<Material>(
          find.descendant(of: _sheet, matching: find.byType(Material)).first);
      expect(material.color, _paletteOf(mode).sheet);
      expect(
        material.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      );
    }, variant: themeModes);

    testWidgets('draws one 40x4 grab handle, 10 px under the top',
        (tester) async {
      final mode = themeModes.currentValue!;
      await _open(tester, builder: _content, mode: mode);
      final handle = find.byKey(const Key('sheetHandle'));
      final rect = tester.getRect(handle);
      final decoration =
          tester.widget<Container>(handle).decoration as BoxDecoration;

      expect(rect.size, const Size(40, 4));
      expect(rect.center.dx, 195);
      expect(rect.top - tester.getRect(_sheet).top, 10);
      expect(decoration.color, _paletteOf(mode).tickOff);
      expect(decoration.borderRadius, BorderRadius.circular(2));
    }, variant: themeModes);

    testWidgets('puts 14 px under the handle, 20 px at the sides, 34 below',
        (tester) async {
      await _open(tester, builder: _content);
      final handle = tester.getRect(find.byKey(const Key('sheetHandle')));
      final content = tester.getRect(find.byKey(const Key('content')));
      final sheet = tester.getRect(_sheet);

      expect(content.top - handle.bottom, 14);
      expect(content.left, 20);
      expect(content.right, 390 - 20);
      expect(sheet.bottom - content.bottom, 34);
      expect(sheet.bottom, 844);
    });

    testWidgets('is as tall as its content', (tester) async {
      await _open(tester, builder: _content);
      expect(tester.getSize(_sheet).height, 10 + 4 + 14 + 100 + 34);
    });

    testWidgets('dims the page with the scrim', (tester) async {
      await _open(tester, builder: _content);
      final barrier =
          tester.widget<ModalBarrier>(find.byType(ModalBarrier).last);
      expect(barrier.color, AppColors.scrim);
    });
  });

  group('behaviour', () {
    testWidgets('returns the popped value', (tester) async {
      late Future<Object?> result;
      await _open(
        tester,
        onOpened: (r) => result = r,
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).pop('done'),
          child: const Text('finish'),
        ),
      );
      await tester.tap(find.text('finish'));
      await tester.pumpAndSettle();

      expect(await result, 'done');
      expect(_sheet, findsNothing);
    });

    testWidgets('a tap on the scrim closes it with null', (tester) async {
      late Future<Object?> result;
      await _open(tester, builder: _content, onOpened: (r) => result = r);
      await tester.tapAt(const Offset(195, 40));
      await tester.pumpAndSettle();

      expect(await result, isNull);
      expect(_sheet, findsNothing);
    });

    testWidgets('tall content scrolls inside a sheet capped at 90 percent',
        (tester) async {
      await _open(
        tester,
        builder: (_) => ListView(
          children: [for (var i = 0; i < 60; i++) Text('row $i')],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(_sheet).height, closeTo(844 * 0.9, 0.001));
      expect(find.text('row 59'), findsNothing);
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(find.text('row 59'), findsOneWidget);
    });

    testWidgets('rises above the keyboard', (tester) async {
      await _open(tester, builder: _content);
      final before = tester.getRect(find.byKey(const Key('content'))).bottom;

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byKey(const Key('content'))).bottom,
          before - 300);
    });
  });
}

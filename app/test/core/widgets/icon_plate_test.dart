import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/app_layout.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/icon_plate.dart';
import 'package:trooptrak_final_application/core/widgets/slidable_row.dart';
import 'package:trooptrak_final_application/core/widgets/state_tone.dart';

import '../../helpers/pump_app.dart';

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

void main() {
  testWidgets('IconPlate tints its tone behind a legible icon', (tester) async {
    final mode = themeModes.currentValue!;
    final palette = _paletteOf(mode);
    await tester.pumpThemed(
      const IconPlate(Icons.flight_takeoff_rounded, tone: StateTone.leave),
      mode: mode,
    );
    final box = tester.widget<DecoratedBox>(find.descendant(
        of: find.byType(IconPlate), matching: find.byType(DecoratedBox)));
    expect(
        (box.decoration as BoxDecoration).color, StateTone.leave.tint(palette));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, StateTone.leave.text(palette));
    expect(icon.icon, Icons.flight_takeoff_rounded);
    expect(tester.getSize(find.byType(IconPlate)),
        const Size.square(AppLayout.iconPlateSize));
  }, variant: themeModes);

  group('SlidableRow', () {
    testWidgets('without callbacks the row is returned as it is',
        (tester) async {
      await tester.pumpThemed(const SlidableRow(child: Text('row')));
      expect(find.text('row'), findsOneWidget);
      expect(find.byType(Slidable), findsNothing);
    });

    testWidgets('each callback adds one action', (tester) async {
      await tester.pumpThemed(SlidableRow(
        onDelete: () {},
        deleteKey: const Key('del'),
        editKey: const Key('edit'),
        child: const SizedBox(height: 60, child: Text('row')),
      ));
      await tester.drag(find.text('row'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('del')), findsOneWidget);
      expect(find.byKey(const Key('edit')), findsNothing);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/widgets/app_list_card.dart';
import 'package:trooptrak_final_application/core/widgets/rank_chip.dart';
import 'package:trooptrak_final_application/core/widgets/rank_plate.dart';
import 'package:trooptrak_final_application/core/widgets/soldier_row.dart';

import '../../helpers/builders.dart';
import '../../helpers/pump_app.dart';

void main() {
  final soldier = buildSoldier(name: 'tan ah kow', rank: 'CPL');

  testWidgets('shows plate, title-cased name, rank chip and note',
      (tester) async {
    await tester.pumpThemed(
        AppListCard(
            children: [SoldierRow(soldier: soldier, note: 'Section IC')]),
        mode: themeModes.currentValue!);
    expect(find.byKey(const Key('person-tan ah kow')), findsOneWidget);
    expect(find.text('Tan Ah Kow'), findsOneWidget);
    expect(find.text('Section IC'), findsOneWidget);
    expect(find.byType(RankPlate), findsOneWidget);
    expect(find.widgetWithText(RankChip, 'CPL'), findsOneWidget);
  }, variant: themeModes);

  testWidgets('fires onTap and shows the trailing widget', (tester) async {
    var taps = 0;
    await tester.pumpThemed(AppListCard(children: [
      SoldierRow(
        soldier: soldier,
        note: 'Section IC',
        trailing: const Icon(Icons.check_circle_rounded),
        onTap: () => taps++,
      ),
    ]));
    await tester.tap(find.text('Tan Ah Kow'));
    expect(taps, 1);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('dimmed fades the row and still takes taps', (tester) async {
    var taps = 0;
    await tester.pumpThemed(AppListCard(children: [
      SoldierRow(
        soldier: soldier,
        note: 'Ineligible',
        dimmed: true,
        trailing: const Icon(Icons.check_circle_rounded),
        onTap: () => taps++,
      ),
    ]));
    await tester.tap(find.text('Tan Ah Kow'));
    expect(taps, 1);
    final faded = tester.widgetList<Opacity>(find.descendant(
        of: find.byType(SoldierRow), matching: find.byType(Opacity)));
    expect(faded.map((o) => o.opacity), [0.45, 0.45]);
    expect(
        find.ancestor(
            of: find.byIcon(Icons.check_circle_rounded),
            matching: find.byType(Opacity)),
        findsNothing);
  });
}

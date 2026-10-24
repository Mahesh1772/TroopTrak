import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/app_card.dart';

import '../../helpers/pump_app.dart';

void main() {
  Material cardOf(WidgetTester tester) => tester.widget<Material>(find
      .descendant(of: find.byType(AppCard), matching: find.byType(Material))
      .first);

  testWidgets('defaults to the card colour and a 20 px radius', (tester) async {
    final mode = themeModes.currentValue!;
    await tester.pumpThemed(const AppCard(child: Text('in')), mode: mode);
    final material = cardOf(tester);
    expect(material.color,
        (mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light).card);
    expect(material.borderRadius, BorderRadius.circular(20));
  }, variant: themeModes);

  testWidgets('takes its own colour and radius', (tester) async {
    final mode = themeModes.currentValue!;
    await tester.pumpThemed(
        const AppCard(color: Colors.red, radius: 12, child: Text('in')),
        mode: mode);
    final material = cardOf(tester);
    expect(material.color, Colors.red);
    expect(material.borderRadius, BorderRadius.circular(12));
  }, variant: themeModes);
}

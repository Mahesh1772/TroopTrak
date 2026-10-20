import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/widgets/app_scaffold.dart';
import 'package:trooptrak_final_application/core/widgets/app_search_field.dart';
import 'package:trooptrak_final_application/core/widgets/expandable_count_tile.dart';
import 'package:trooptrak_final_application/core/widgets/info_row.dart';
import 'package:trooptrak_final_application/core/widgets/person_tile.dart';
import 'package:trooptrak_final_application/core/widgets/section_header.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('AppScaffold shows title, actions, body and FAB', (tester) async {
    await tester.pumpThemed(
      AppScaffold(
        title: 'Nominal Roll',
        actions: const [Icon(Icons.person)],
        floatingActionButton: FloatingActionButton(onPressed: () {}),
        body: const Text('body'),
      ),
      mode: themeModes.currentValue!,
      wrapInScaffold: false,
    );
    expect(find.text('Nominal Roll'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  }, variant: themeModes);

  testWidgets('AppScaffold without title has no app bar', (tester) async {
    await tester.pumpThemed(const AppScaffold(body: Text('x')),
        wrapInScaffold: false);
    expect(find.byType(AppBar), findsNothing);
  });

  testWidgets('AppSearchField reports typed text', (tester) async {
    final typed = <String>[];
    await tester.pumpThemed(AppSearchField(onChanged: typed.add),
        mode: themeModes.currentValue!);
    expect(find.text('Search...'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'tan');
    expect(typed.last, 'tan');
  }, variant: themeModes);

  testWidgets('InfoRow shows icon, title and content', (tester) async {
    await tester.pumpThemed(
      const InfoRow(
          icon: Icons.cake, title: 'Date of Birth', content: '5 Jul 2000'),
      mode: themeModes.currentValue!,
    );
    expect(find.byIcon(Icons.cake), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('5 Jul 2000'), findsOneWidget);
  }, variant: themeModes);

  testWidgets('SectionHeader shows title and caption', (tester) async {
    await tester.pumpThemed(
      const SectionHeader('Participation Strength', caption: '3'),
      mode: themeModes.currentValue!,
    );
    expect(find.text('Participation Strength'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  }, variant: themeModes);

  testWidgets('PersonTile shows name, reason, trailing and fires onTap',
      (tester) async {
    var taps = 0;
    await tester.pumpThemed(
      PersonTile(
        name: 'Tan Ah Kow',
        rank: 'CPL',
        subtitle: 'Ex RMJ',
        trailing: const Icon(Icons.check),
        onTap: () => taps++,
      ),
      mode: themeModes.currentValue!,
    );
    expect(find.text('Tan Ah Kow'), findsOneWidget);
    expect(find.text('Ex RMJ'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.text('Tan Ah Kow'));
    expect(taps, 1);
  }, variant: themeModes);

  testWidgets('ExpandableCountTile shows count and expands to children',
      (tester) async {
    await tester.pumpThemed(
      const SingleChildScrollView(
        child: ExpandableCountTile(
          title: 'Total Officers',
          subtitle: '2 In Camp',
          count: '2 / 3',
          leading: Icon(Icons.star),
          children: [Text('Officer A'), Text('Officer B')],
        ),
      ),
      mode: themeModes.currentValue!,
    );
    expect(find.text('Total Officers'), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.text('Officer A'), findsNothing);

    await tester.tap(find.text('Total Officers'));
    await tester.pumpAndSettle();
    expect(find.text('Officer A'), findsOneWidget);
    expect(find.text('Officer B'), findsOneWidget);
  }, variant: themeModes);

  testWidgets('ExpandableCountTile shows empty message without children',
      (tester) async {
    await tester.pumpThemed(const SingleChildScrollView(
      child: ExpandableCountTile(
        title: 'On MA',
        subtitle: '0 In Camp',
        count: '0',
        leading: Icon(Icons.star),
        children: [],
      ),
    ));
    await tester.tap(find.text('On MA'));
    await tester.pumpAndSettle();
    expect(find.text('No personnel'), findsOneWidget);
  });
}

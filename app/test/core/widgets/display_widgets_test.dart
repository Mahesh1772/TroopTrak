import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/widgets/app_scaffold.dart';
import 'package:trooptrak_final_application/core/widgets/app_search_field.dart';
import 'package:trooptrak_final_application/core/widgets/definition_list.dart';
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

  testWidgets('DefinitionList puts a hairline between rows only',
      (tester) async {
    await tester.pumpThemed(
      const DefinitionList(entries: [('Blood Type', 'O+'), ('ORD', '1 JAN')]),
      mode: themeModes.currentValue!,
    );
    expect(find.text('Blood Type'), findsOneWidget);
    expect(find.text('1 JAN'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  }, variant: themeModes);

  testWidgets('SectionHeader shows title and caption', (tester) async {
    await tester.pumpThemed(
      const SectionHeader('Participation Strength', caption: '3'),
      mode: themeModes.currentValue!,
    );
    expect(find.text('Participation Strength'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  }, variant: themeModes);
}

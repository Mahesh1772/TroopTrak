import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty MaterialApp builds', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

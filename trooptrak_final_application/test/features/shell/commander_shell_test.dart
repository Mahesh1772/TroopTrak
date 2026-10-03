import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/features/shell/presentation/pages/commander_shell.dart';

import '../../helpers/pump_app.dart';

class _Counter extends StatefulWidget {
  const _Counter(this.label);

  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => setState(() => taps++),
        child: Text('${widget.label} $taps'),
      );
}

void main() {
  late List<String> built;

  Future<RouteRecorder> pumpShell(WidgetTester tester,
      {ThemeMode mode = ThemeMode.dark}) async {
    built = [];
    WidgetBuilder tab(String label) => (_) {
          built.add(label);
          return _Counter(label);
        };
    final recorder = RouteRecorder();
    await tester.pumpApp(
      CommanderShell(
        home: tab('home'),
        nominalRoll: tab('roll'),
        conductTracker: tab('conducts'),
        guardDuty: tab('duty'),
      ),
      mode: mode,
      observers: [recorder],
    );
    return recorder;
  }

  String title(WidgetTester tester) => tester
      .widget<Text>(
          find.descendant(of: find.byType(AppBar), matching: find.byType(Text)))
      .data!;

  testWidgets('four tabs in source order; home first', (tester) async {
    await pumpShell(tester, mode: themeModes.currentValue!);
    for (final key in ['home', 'nominalRoll', 'conductTracker', 'guardDuty']) {
      expect(find.byKey(Key(key)), findsOneWidget);
    }
    final xs = [
      for (final key in ['home', 'nominalRoll', 'conductTracker', 'guardDuty'])
        tester.getCenter(find.byKey(Key(key))).dx,
    ];
    expect(xs, [...xs]..sort());
    expect(title(tester), 'Dashboard');
    expect(find.text('home 0'), findsOneWidget);
  }, variant: themeModes);

  testWidgets('titles follow the tab; tabs build lazily and keep state',
      (tester) async {
    await pumpShell(tester);
    expect(built, ['home']);
    await tester.tap(find.text('home 0'));
    await tester.pump();

    for (final (key, expected) in [
      ('nominalRoll', 'Nominal Roll'),
      ('conductTracker', 'Conduct Tracker'),
      ('guardDuty', 'Guard Duty'),
    ]) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      expect(title(tester), expected);
    }
    expect(built.toSet(), {'home', 'roll', 'conducts', 'duty'});

    await tester.tap(find.byKey(const Key('home')));
    await tester.pumpAndSettle();
    expect(title(tester), 'Dashboard');
    expect(find.text('home 1'), findsOneWidget);
  });

  testWidgets('profile icon opens the commander profile route', (tester) async {
    final recorder = await pumpShell(tester);
    await tester.tap(find.byKey(const Key('userProfileIcon')));
    await tester.pumpAndSettle();
    expect(recorder.names.last, AppRoutes.commanderProfile);
  });

  testWidgets('system back does not leave the shell', (tester) async {
    await pumpShell(tester);
    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    expect(popScope.canPop, isFalse);
  });
}

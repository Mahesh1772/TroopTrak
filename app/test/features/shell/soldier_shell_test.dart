import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/features/shell/presentation/pages/soldier_shell.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> pumpShell(WidgetTester tester,
          {ThemeMode mode = ThemeMode.dark}) =>
      tester.pumpApp(
        SoldierShell(
          profile: (_) => const Text('profile tab'),
          conductTracker: (_) => const Text('conducts tab'),
          guardDuty: (_) => const Text('duty tab'),
        ),
        mode: mode,
      );

  Gradient? pill(WidgetTester tester, String tab) => (tester
          .widget<DecoratedBox>(find
              .descendant(
                  of: find.byKey(ValueKey('navPill-$tab')),
                  matching: find.byType(DecoratedBox))
              .first)
          .decoration as BoxDecoration)
      .gradient;

  testWidgets('three tabs in source order, profile first, no app bar',
      (tester) async {
    await pumpShell(tester, mode: themeModes.currentValue!);
    final xs = [
      for (final key in ['myProfile', 'conductTracker', 'guardDuty'])
        tester.getCenter(find.byKey(Key(key))).dx,
    ];
    expect(xs, [...xs]..sort());
    expect(find.text('profile tab'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
  }, variant: themeModes);

  testWidgets('three NavigationBar destinations; the active one has the pill',
      (tester) async {
    await pumpShell(tester, mode: themeModes.currentValue!);
    final bar = find.byType(NavigationBar);
    expect(tester.widget<NavigationBar>(bar).destinations, hasLength(3));
    for (final label in ['My Profile', 'Conducts', 'Guard Duty']) {
      expect(find.text(label), findsOneWidget);
    }

    expect((pill(tester, 'myProfile')! as LinearGradient).colors,
        AppColors.navPillGradient);
    expect(pill(tester, 'conductTracker'), isNull);
    await tester.tap(find.byKey(const Key('conductTracker')));
    await tester.pumpAndSettle();
    expect(pill(tester, 'myProfile'), isNull);
    expect(pill(tester, 'conductTracker'), isNotNull);
  }, variant: themeModes);

  testWidgets('tabs switch content; the shell is always dark', (tester) async {
    await pumpShell(tester, mode: ThemeMode.light);
    await tester.tap(find.byKey(const Key('conductTracker')));
    await tester.pumpAndSettle();
    expect(find.text('conducts tab'), findsOneWidget);
    await tester.tap(find.byKey(const Key('guardDuty')));
    await tester.pumpAndSettle();
    expect(find.text('duty tab'), findsOneWidget);
    expect(Theme.of(tester.element(find.text('duty tab'))).brightness,
        Brightness.dark);
  });
}

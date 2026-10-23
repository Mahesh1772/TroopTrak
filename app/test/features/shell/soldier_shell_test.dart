import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_layout.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/theme/dark_theme.dart';
import 'package:trooptrak_final_application/core/theme/light_theme.dart';
import 'package:trooptrak_final_application/core/theme/theme_manager.dart';
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

  testWidgets('tabs switch content', (tester) async {
    await pumpShell(tester, mode: themeModes.currentValue!);
    await tester.tap(find.byKey(const Key('conductTracker')));
    await tester.pumpAndSettle();
    expect(find.text('conducts tab'), findsOneWidget);
    await tester.tap(find.byKey(const Key('guardDuty')));
    await tester.pumpAndSettle();
    expect(find.text('duty tab'), findsOneWidget);
  }, variant: themeModes);

  testWidgets('the shell follows the theme mode instead of forcing dark',
      (tester) async {
    final mode = themeModes.currentValue!;
    await pumpShell(tester, mode: mode);
    final palette = mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
    final theme = Theme.of(tester.element(find.text('profile tab')));
    expect(theme.brightness,
        mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
    expect(theme.extension<AppPalette>(), palette);
    final bar = find.byType(NavigationBar);
    final material = tester.widget<Material>(
        find.descendant(of: bar, matching: find.byType(Material)).first);
    expect(material.color, palette.navBar);
  }, variant: themeModes);

  testWidgets('switching ThemeManager restyles the open shell', (tester) async {
    useDesignSurface(tester);
    final manager = ThemeManager();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: manager,
        child: ScreenUtilInit(
          designSize: AppLayout.designSize,
          builder: (_, __) => Consumer<ThemeManager>(
            builder: (_, manager, __) => MaterialApp(
              theme: buildLightTheme(),
              darkTheme: buildDarkTheme(),
              themeMode: manager.themeMode,
              home: SoldierShell(
                profile: (_) => const Text('profile tab'),
                conductTracker: (_) => const Text('conducts tab'),
                guardDuty: (_) => const Text('duty tab'),
              ),
            ),
          ),
        ),
      ),
    );
    Brightness brightness() =>
        Theme.of(tester.element(find.text('profile tab'))).brightness;

    expect(brightness(), Brightness.dark);
    manager.setDark(false);
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.light);
    manager.setDark(true);
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.dark);
  });
}

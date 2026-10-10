import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trooptrak_final_application/core/services/clock.dart';
import 'package:trooptrak_final_application/core/theme/dark_theme.dart';
import 'package:trooptrak_final_application/core/theme/light_theme.dart';
import 'package:trooptrak_final_application/core/theme/theme_manager.dart';

import 'fake_clock.dart';

const designSize = Size(450, 1000);

final themeModes = ValueVariant<ThemeMode>({ThemeMode.light, ThemeMode.dark});

void useDesignSurface(WidgetTester tester) {
  tester.view.physicalSize = designSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

class RouteRecorder extends NavigatorObserver {
  final pushed = <Route<dynamic>>[];

  List<String?> get names => pushed.map((r) => r.settings.name).toList();

  Object? get lastArguments => pushed.last.settings.arguments;

  final popped = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      pushed.add(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) pushed.add(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      popped.add(route);
}

Route<dynamic> stubRoute(RouteSettings settings) => MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => Scaffold(body: Text('route:${settings.name}')),
    );

extension PumpApp on WidgetTester {
  Future<void> pumpThemed(
    Widget child, {
    ThemeMode mode = ThemeMode.dark,
    bool wrapInScaffold = true,
  }) =>
      pumpApp(
        wrapInScaffold ? Scaffold(body: child) : child,
        mode: mode,
      );

  Future<void> pumpApp(
    Widget home, {
    ThemeMode mode = ThemeMode.dark,
    List<SingleChildWidget> providers = const [],
    Clock? clock,
    RouteFactory onGenerateRoute = stubRoute,
    List<NavigatorObserver> observers = const [],
  }) async {
    useDesignSurface(this);
    await pumpWidget(
      MultiProvider(
        providers: [
          Provider<Clock>.value(
              value: clock ?? FixedClock(DateTime(2023, 7, 5, 9))),
          ChangeNotifierProvider<ThemeManager>(
              create: (_) => ThemeManager(initialMode: mode)),
          ...providers,
        ],
        child: ScreenUtilInit(
          designSize: designSize,
          builder: (_, __) => MaterialApp(
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: mode,
            home: home,
            onGenerateRoute: onGenerateRoute,
            navigatorObservers: observers,
          ),
        ),
      ),
    );
  }
}

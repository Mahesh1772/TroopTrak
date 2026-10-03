import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/theme_manager.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.providers,
    this.initialRoute = AppRoutes.root,
  });

  final List<SingleChildWidget> providers;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: ScreenUtilInit(
        designSize: const Size(450, 1000),
        builder: (_, __) {
          final light = buildLightTheme();
          final dark = buildDarkTheme();
          return Consumer<ThemeManager>(
            builder: (_, themeManager, __) => MaterialApp(
              title: 'TroopTrak',
              debugShowCheckedModeBanner: false,
              theme: light,
              darkTheme: dark,
              themeMode: themeManager.themeMode,
              initialRoute: initialRoute,
              onGenerateRoute: AppRouter.onGenerateRoute,
            ),
          );
        },
      ),
    );
  }
}

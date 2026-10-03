import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/dark_theme.dart';
import 'package:trooptrak_final_application/core/theme/light_theme.dart';

const designSize = Size(450, 1000);

final themeModes = ValueVariant<ThemeMode>({ThemeMode.light, ThemeMode.dark});

void useDesignSurface(WidgetTester tester) {
  tester.view.physicalSize = designSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

extension PumpApp on WidgetTester {
  Future<void> pumpThemed(
    Widget child, {
    ThemeMode mode = ThemeMode.dark,
    bool wrapInScaffold = true,
  }) async {
    useDesignSurface(this);
    await pumpWidget(
      ScreenUtilInit(
        designSize: designSize,
        builder: (_, __) => MaterialApp(
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: mode,
          home: wrapInScaffold ? Scaffold(body: child) : child,
        ),
      ),
    );
  }
}

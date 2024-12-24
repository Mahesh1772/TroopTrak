import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/theme/theme.dart';
import 'package:trooptrak_final_application/core/init/app_init.dart';
import 'package:trooptrak_final_application/core/providers/provider_setup.dart';
import 'package:trooptrak_final_application/features/navigation/presentation/pages/main_navigation_screen.dart';

void main() async {
  await initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(450, 1000),
      child: MultiProvider(
        providers: getProviders(),
        child: MaterialApp(
          title: 'TroopTrak',
          theme: lightTheme,
          darkTheme: darkTheme,
          home: const MainNavigationScreen(),
        ),
      ),
    );
  }
}

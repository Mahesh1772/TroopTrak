import 'package:firebase_project_2/phone_authentication/provider/auth_provider.dart';
import 'package:firebase_project_2/phone_authentication/wrapper.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/main.dart';
import 'package:firebase_project_2/themes/dark_theme.dart';
import 'package:firebase_project_2/themes/light_theme.dart';
import 'package:firebase_project_2/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_project_2/phone_authentication/commander_or_man_choice_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_project_2/firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_project_2/user_models/user_details.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

int? isViewed;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isViewed = prefs.getInt('onBoard');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

ThemeManager _themeManager = ThemeManager();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (BuildContext context, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenUserData(),
          ),
          ChangeNotifierProvider(
            create: (context) => AuthProvider(),
          ),
        ],
        child: MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: _themeManager.themeMode,
          home: (() {
            if (isViewed == 1) {
              return const Wrapper();
            } else if (isViewed == 2) {
              return const MyAppCommander();
            } else {
              return const CommanderOrManSelectScreen();
            }
          }()),
        ),
      ),
      designSize: const Size(450, 1000),
    );
  }
}

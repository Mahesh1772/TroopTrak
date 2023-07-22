import 'package:firebase_project_2/phone_authentication/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_project_2/phone_authentication/commander_or_man_choice_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_project_2/firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_project_2/user_models/user_details.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

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
        child: const MaterialApp(
          home: CommanderOrManSelectScreen(),
        ),
      ),
      designSize: const Size(450, 1000),
    );
  }
}

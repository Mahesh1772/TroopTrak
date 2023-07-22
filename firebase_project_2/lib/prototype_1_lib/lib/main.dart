import 'package:flutter/material.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/sign_in_assets/home/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyAppCommander());
}

class MyAppCommander extends StatelessWidget {
  const MyAppCommander({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (BuildContext context, child) => ChangeNotifierProvider(
        create: (context) => UserData(),
        child: const MaterialApp(
          home: Wrapper(),
        ),
      ),
      designSize: const Size(450, 1000),
    );
  }
}

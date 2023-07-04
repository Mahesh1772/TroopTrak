import 'package:firebase_project_1/user_model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_project_1/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
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
    return ChangeNotifierProvider(
      create: (context) => UserData(),
      child: const MaterialApp(
        home: Wrapper(),
        //return const MaterialApp(
        //  home: Wrapper(),
      ),
    );
  }
}

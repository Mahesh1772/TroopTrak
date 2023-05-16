import 'package:flutter/material.dart';
import 'package:prototype_1/n.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prototype_1/firebase_options.dart';

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
    return const MaterialApp(
      home: Wrapper(),
    );
  }
}
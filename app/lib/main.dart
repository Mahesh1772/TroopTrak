import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'core/di/firebase_bootstrap.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await initFirebase();
  final dependencies = await AppDependencies.create();
  runApp(App(providers: dependencies.providers));
}

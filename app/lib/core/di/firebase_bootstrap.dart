import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

abstract final class EmulatorConfig {
  static const enabled = bool.fromEnvironment('USE_EMULATOR');
  static const firestorePort = 8080;
  static const authPort = 9099;
  static const _hostOverride = String.fromEnvironment('EMULATOR_HOST');

  static String get host {
    if (_hostOverride.isNotEmpty) return _hostOverride;
    final androidDevice =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return androidDevice ? '10.0.2.2' : 'localhost';
  }
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!EmulatorConfig.enabled) return;
  FirebaseFirestore.instance
      .useFirestoreEmulator(EmulatorConfig.host, EmulatorConfig.firestorePort);
  await FirebaseAuth.instance
      .useAuthEmulator(EmulatorConfig.host, EmulatorConfig.authPort);
}

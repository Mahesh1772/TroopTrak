import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trooptrak_final_application/app.dart';
import 'package:trooptrak_final_application/core/di/firebase_bootstrap.dart';
import 'package:trooptrak_final_application/core/di/injection.dart';
import 'package:trooptrak_final_application/firebase_options.dart';

/// Talks to the Firebase emulators the app is pointed at by `USE_EMULATOR`.
abstract final class Emulators {
  static final _projectId = DefaultFirebaseOptions.currentPlatform.projectId;

  static Uri _uri(int port, String path) => Uri.parse(
      'http://${EmulatorConfig.host}:$port/emulator/v1/projects/$_projectId/$path');

  static Future<void> start() async {
    if (!EmulatorConfig.enabled) {
      fail('Run with --dart-define=USE_EMULATOR=true; '
          'integration tests never touch the live project.');
    }
    await initFirebase();
    await FirebaseFirestore.instance.clearPersistence();
  }

  /// Empties Firestore and Auth, signs out and clears preferences.
  static Future<void> reset() async {
    await _send('DELETE',
        _uri(EmulatorConfig.firestorePort, 'databases/(default)/documents'));
    await _send('DELETE', _uri(EmulatorConfig.authPort, 'accounts'));
    await FirebaseAuth.instance.signOut();
    await (await SharedPreferences.getInstance()).clear();
  }

  /// The latest OTP the Auth emulator issued for [phoneNumber].
  static Future<String> verificationCode(String phoneNumber) async {
    final body =
        await _send('GET', _uri(EmulatorConfig.authPort, 'verificationCodes'));
    final json = jsonDecode(body) as Map<String, dynamic>;
    final codes = (json['verificationCodes'] as List)
        .cast<Map<String, dynamic>>()
        .where((c) => c['phoneNumber'] == phoneNumber);
    if (codes.isEmpty) fail('No OTP issued for $phoneNumber');
    return codes.last['code'] as String;
  }

  static Future<String> _send(String method, Uri uri) async {
    final client = HttpClient();
    try {
      final response = await (await client.openUrl(method, uri)).close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != HttpStatus.ok) {
        fail('$method $uri -> ${response.statusCode}: $body');
      }
      return body;
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>?> read(String path) async =>
      (await FirebaseFirestore.instance
              .doc(path)
              .get(const GetOptions(source: Source.server)))
          .data();

  static Future<List<Map<String, dynamic>>> readAll(String collection) async =>
      [
        for (final d in (await FirebaseFirestore.instance
                .collection(collection)
                .get(const GetOptions(source: Source.server)))
            .docs)
          d.data(),
      ];
}

Future<void> launchApp(WidgetTester tester) async {
  final dependencies = await AppDependencies.create();
  await tester.pumpWidget(App(providers: dependencies.providers));
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trooptrak_final_application/core/services/preferences_service.dart';

void main() {
  Future<PreferencesService> serviceWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return PreferencesService.create();
  }

  group('onBoard', () {
    test('is null when unset', () async {
      expect((await serviceWith({})).onBoard, isNull);
    });

    test('reads the stored value', () async {
      expect((await serviceWith({'onBoard': 2})).onBoard, 2);
    });

    test('writes and persists the value', () async {
      final service = await serviceWith({});
      await service.setOnBoard(1);
      expect(service.onBoard, 1);
      expect((await SharedPreferences.getInstance()).getInt('onBoard'), 1);
    });
  });

  group('isSignedIn', () {
    test('defaults to false', () async {
      expect((await serviceWith({})).isSignedIn, isFalse);
    });

    test('reads the stored is_signedin flag', () async {
      expect((await serviceWith({'is_signedin': true})).isSignedIn, isTrue);
    });

    test('writes and persists the flag', () async {
      final service = await serviceWith({});
      await service.setSignedIn(true);
      expect(service.isSignedIn, isTrue);
      expect(
          (await SharedPreferences.getInstance()).getBool('is_signedin'), true);
    });
  });

  group('isDarkTheme', () {
    test('is null when nothing is saved', () async {
      expect((await serviceWith({})).isDarkTheme, isNull);
    });

    test('round trips dark and light', () async {
      final service = await serviceWith({});
      await service.setDarkTheme(false);
      expect(service.isDarkTheme, isFalse);
      await service.setDarkTheme(true);
      expect(service.isDarkTheme, isTrue);
    });

    test('survives a new instance over the same store', () async {
      final service = await serviceWith({});
      await service.setDarkTheme(false);
      expect((await PreferencesService.create()).isDarkTheme, isFalse);
      expect(
          (await SharedPreferences.getInstance()).getBool('theme_dark'), false);
    });
  });

  test('clearAll removes every key', () async {
    final service = await serviceWith({
      'onBoard': 1,
      'is_signedin': true,
      'theme_dark': false,
      'other': 'x',
    });
    await service.clearAll();
    expect(service.onBoard, isNull);
    expect(service.isSignedIn, isFalse);
    expect(service.isDarkTheme, isNull);
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
  });
}

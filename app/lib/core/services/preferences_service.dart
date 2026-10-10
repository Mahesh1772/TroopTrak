import 'package:shared_preferences/shared_preferences.dart';

import '../constants/pref_keys.dart';
import '../error/exceptions.dart';

class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async =>
      PreferencesService(await SharedPreferences.getInstance());

  int? get onBoard => _prefs.getInt(PrefKeys.onBoard);

  Future<void> setOnBoard(int value) =>
      _write(_prefs.setInt(PrefKeys.onBoard, value));

  bool get isSignedIn => _prefs.getBool(PrefKeys.isSignedIn) ?? false;

  Future<void> setSignedIn(bool value) =>
      _write(_prefs.setBool(PrefKeys.isSignedIn, value));

  Future<void> clearAll() => _write(_prefs.clear());

  Future<void> _write(Future<bool> operation) async {
    if (!await operation) {
      throw const CacheException('Could not save preferences.');
    }
  }
}

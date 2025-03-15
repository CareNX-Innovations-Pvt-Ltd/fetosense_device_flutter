import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();
  factory SharedPrefsHelper() => _instance;
  SharedPrefsHelper._internal();

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save a string value
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Save a boolean value
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Save an integer value
  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  /// Get an integer value
  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Remove a value
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  /// Clear all stored data
  Future<void> clear() async {
    await _prefs?.clear();
  }
}
